    (in-package :cl-user)
    (defpackage :cl-skkserv/google
      (:nicknames :skkserv/google)
      (:use :cl :drakma :yason :flexi-streams :alexandria :named-readtables :papyrus :cl-skkserv/core)
      (:export google-ime-dictionary))
    (in-package :cl-skkserv/google)
    (in-readtable :papyrus)

# Google日本語入力辞書

この辞書はHTTP経由でGoogle日本語入力が提供しているCGI APIを使って変換候補を作る辞書です。

## 使い方

設定ファイルの`*dictionary*`を以下のように上書きすることで使えるようになります。
またSKK辞書に無い文字列の変換を行いたいときの補助辞書としても活用できます。

    (setq *dictionary* (make-instance 'google-ime-dictionary))


## 注意事項

この辞書は次のURLに対して変換候補の要求をGET要求を送信します。
そしてGET要求のため変換文字列はURL上に埋め込まれます。
これはURLがHTTPS経由でもHTTP経由でも変換文字列が誰でも閲覧可能な状態になっていることを意味します。
そのため重要な文章の入力にはこの辞書を使用しないことをお勧めします。

```lisp
(defparameter *URL* "http://www.google.com/transliterate")
```

## クラス

この辞書は如何なるスロットも持ちません。

```lisp
(defclass google-ime-dictionary (dictionary) ())
```

### 変換処理

Google日本語入力が提供するCGI APIは入力文字列に対して文節への分解処理を行いその各文節に対して変換候補の列を返します。
例えば「ここではきものをぬぐ」を要求した場合は以下のようなJSONが返ってきます。

```json
[
  ["ここでは",
    ["ここでは", "個々では", "此処では"],
  ],
  ["きものを",
    ["着物を", "きものを", "キモノを"],
  ],
  ["ぬぐ",
    ["脱ぐ", "ぬぐ", "ヌグ"],
  ],
]
```


この辞書では各変換文字列に対してすべての組合せを変換候補文字列として列にして返します。
またこの辞書は、オフラインの時に例外出力に例外を書きこみ空列を返します。

```lisp
(defmethod convert append ((d google-ime-dictionary) (s string))
  (handler-case
	  (let* ((*drakma-default-external-format* :utf-8)
		 (params `(("langpair" . "ja-Hira|ja") ("text" . ,s)))
		 (stream (http-request *URL* :parameters params :want-stream t)))
		(setf (flexi-stream-external-format stream) :utf-8)
		(let ((candidates (mapcar #'second (parse stream :object-as :plist))))
		  (flet ((scat (&rest s) (apply #'concatenate 'string s)))
			(apply #'map-product #'scat candidates))))
	(error () (warn "CL-SKKSERV/GOOGLE:WARN: ~a is not active.~%" *URL*))))
		   
```


## 補完処理

この辞書では補完処理(SKKサーバーの4番要求)を実装していません。
もしこの辞書に対して要求がきた場合は空列が返されます。
