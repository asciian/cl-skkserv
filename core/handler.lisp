(in-package :cl)
(defpackage :lime/core/handler
  (:use :cl :esrap :asdf)
  (:import-from :lime/core/dictionary convert complete)
  (:export handler))
(in-package :lime/core/handler)

(defrule convert-request (and #\1 (+ (not #\space)) #\space)
  (:lambda (list) (list (parse-integer (first list)) (format nil "~{~a~}" (second list)))))
(defrule complete-request (and #\4 (+ (not #\space)) #\space)
  (:lambda (list) (list (parse-integer (first list)) (format nil "~{~a~}" (second list)))))
(defrule other-request (or #\0 #\2 #\3 #\5)
  (:lambda (list) (list (parse-integer list))))
(defrule request (or convert-request
                     complete-request
                     other-request))

(defun chomp (s)
  (let ((end (or (position (code-char 13) s)
                 (position (code-char 10) s))))
    (if end (subseq s 0 end) s)))

(defun handler (stream dictionary)
  ;; http://umiushi.org/~wac/yaskkserv/#protocol
  (let* ((line (read-line stream))
         (request (parse 'request (chomp line))))
    (case (first request)
      (1 (format stream "1/~{~A/~} " (convert dictionary (second request))))
      (2 (format stream "~a " (component-version (find-system :lime))))
      (3 (format stream "hostname:addr:...: "))
      (4 (format stream "4/~{~A/~}~%" (complete dictionary (second request)))))
    (force-output stream)
    (first request)))
