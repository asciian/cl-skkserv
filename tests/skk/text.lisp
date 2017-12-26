(in-package :cl)
(defpackage :lime/tests/skk/text
  (:use :cl :1am :lime/skk/text :lime/core/dictionary))
(in-package :lime/tests/skk/text)

(defparameter *dictionary* nil)

(test skk-textdictionary
      ;;生成
      (is (setq *dictionary* (make-instance 'skk-text-dictionary :pathname #p"./SKK-JISYO.L")))
      ;;検索
      (is (string= "見" (first (convert *dictionary* "みr"))))
      ;;補完
      (is (string= "みわたs" (first (complete *dictionary* "み")))))
