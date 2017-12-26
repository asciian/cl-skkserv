(in-package :cl)
(defpackage :lime/tests/skk/lisp
  (:use :cl :1am :lime/skk/lisp :lime/core/dictionary))
(in-package :lime/tests/skk/lisp)

(defparameter *dictionary* nil)

(test skk-lisp-dictionary
      ;;生成
      (is (setq *dictionary* (make-instance 'skk-lisp-dictionary :pathname #p"./SKK-JISYO.L")))
      ;;検索
      (is (string= "DOS/V" (first (convert *dictionary* "dosv"))))
      ;;補完
      (is (string= "dosv" (first (complete *dictionary* "dosv")))))

