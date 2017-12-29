    (in-package :cl-skkserv/skk)
    (in-readtable :papyrus)

# テキスト辞書

SKK辞書においてもっとも基本的な辞書です。
特殊な処理をせずに辞書内の文字列をそのまま検索結果として返すクラスです。

## 使い方

以下の様に設定ファイル内で`*dictionary*`変数を上書きしてください。

    (setq *dictionary* (make-instance 'skk-text-dictionary :pathname #p"/path/to/dictionary")

なおクラス生成時には必ず辞書のパス名を指定してください。

## クラス

この辞書クラスは`skk-text-dictionary`を言うクラス名で宣言されており、パス名と辞書データの二つを保持します。

```lisp
(defclass skk-text-dictionary (dictionary)
  ((pathname :initarg :pathname :reader pathname-of)
   (table :accessor table-of)))
```

### 初期化

初期化時にはパス名から自動で辞書テーブルが生成されます。


```lisp
(defmethod initialize-instance :after ((dict skk-text-dictionary) &rest initargs)
  (declare (ignore initargs))
  (setf (table-of dict) (make-table (pathname-of dict))))
```

### 変換機能

変換候補はハッシュテーブルを検索した結果になります。
このとき自動で数値項目とS式項目を取り除きます。

```lisp
(defmethod convert append ((d skk-text-dictionary) (s string))
  (remove-if (disjoin #'lispp #'numericp) (gethash s (table-of d))))
```

### 補完機能

補完候補はハッシュテーブルの項目名から生成されます。

```lisp
(defmethod complete append ((d skk-text-dictionary) (s string))
  (loop :for key :being :the :hash-keys :of (table-of d)
        :when (scan (format nil "^~a" s) key) :collect key))
```
