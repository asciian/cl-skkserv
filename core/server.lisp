(in-package :cl)
(defpackage :lime/core/server
  (:use :cl :esrap :asdf :usocket)
  (:import-from :lime/core/dictionary convert)
  (:export server-start handler))
(in-package :lime/core/server)

(defrule disconnect-request #\0
  (:lambda (char) (list char)))
(defrule convert-request (and #\1 (+ (not #\space)) #\space)
  (:lambda (list) (list (first list) (format nil "~{~a~}" (second list)))))
(defrule version-request #\2
  (:lambda (char) (list char)))
(defrule name-request #\3
  (:lambda (char) (list char)))
(defrule request (or disconnect-request
                     convert-request
                     version-request
                     name-request))
                     
(defun chomp (s)
  (let ((end (or (position (code-char 13) s)
                 (position (code-char 10) s))))
    (if end (subseq s 0 end) s)))

(defun handler (stream address port dictionary)
  ;; http://umiushi.org/~wac/yaskkserv/#protocol
  (let* ((line (read-line stream))
         (request (parse 'request (chomp line))))
    (case (parse-integer (first request))
      (0 (return-from handler t))
      (1 (format stream "1/~{~A/~} " (convert dictionary (second request))))
      (2 (format stream "~a " (component-version (find-system :lime))))
      (3 (format stream "hostname:addr:...: "))
      (4 (format stream "4/~{~A/~}~%" (convert dictionary (second request))))) ;; FIXME
    (force-output stream)
    (return-from handler nil)))

(defun server-start (&key address port dictionary)
  (socket-server 
   address port
   (lambda (stream)
     (loop :until (handler stream address port dictionary)))))
