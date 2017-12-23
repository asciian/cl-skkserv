(in-package :cl)
(defpackage :lime/skk/pattern
  (:use :cl :esrap :cl-ppcre :alexandria
        :lime/core/dictionary
        :lime/skk/lisp
        :lime/skk/util)
  (:export skk-pattern-dictionary patternp))
(in-package :lime/skk/pattern)

(defrule placeholder (and #\# (? (character-ranges (#\0 #\9))))
  (:lambda (list)
    (case (second list)
      ((#\0 nil) #'identity)
      (#\1 (lambda (n) n))
      (#\2 (lambda (n) n))
      (#\3 (lambda (n) n))
      (#\4 (lambda (n) n))
      (#\5 (lambda (n) n))
      (#\6 (lambda (n) n))
      (#\7 (lambda (n) n))
      (#\8 (lambda (n) n))
      (#\9 (lambda (n) n)))))

(defrule non-placeholder (+ (not placeholder))
  (:lambda (list) (constantly (format nil "~{~a~}" list))))

(defrule digits (+ (character-ranges (#\0 #\9))) (:text t))

(defrule non-digits (+ (not (character-ranges (#\0 #\9)))) (:text t))

(defclass skk-pattern-dictionary (dictionary)
  ((filespec :initarg :filespec :reader filespec)
   (table :initarg :table :accessor table)))

(defun patternp (s) (scan "#" s))

(defmethod initialize-instance :after ((dict skk-pattern-dictionary) &rest initargs)
  (declare (ignore initargs))
  (setf (table dict) (make-table (filespec dict)))
  (maphash (lambda (key value)
             (setf (gethash key (table dict))
                   (remove-if-not (conjoin #'patternp (compose #'not #'lispp)) value))
             (unless (gethash key (table dict))
               (remhash key (table dict))))
           (table dict)))


(defmethod lookup ((dictionary skk-pattern-dictionary) (word string))
  (let* ((arguments (parse '(+ (or digits non-digits)) word))
         (masked (regex-replace-all "[0-9]+" word "#"))
	 (candidates (gethash masked (table dictionary))))
    (flet ((make-candidate (candidate)
             (let ((functions (parse '(+ (or placeholder non-placeholder)) candidate)))
               (format nil "~{~A~}" (mapcar #'funcall functions (append arguments '(nil)))))))
      (mapcar #'make-candidate candidates))))
