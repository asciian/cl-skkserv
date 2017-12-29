    (in-package :cl-user)
    (defpackage :cl-skkserv/user
      (:nicknames :skkserv/user :cl-skkserv-user :skkserv-user)
      (:use :cl :asdf :trivial-download :named-readtables :papyrus
		  :cl-skkserv/core
		  :cl-skkserv/skk
		  :cl-skkserv/google-ime
		  :cl-skkserv/proxy
		  :cl-skkserv/mixed)
      (:export *dictionary* *address* *port* *encoding*))
    (in-package :cl-skkserv/user)
    (in-readtable :papyrus)

# 設定ファイル

<!--
Copyright (C) 2017 asciian

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software Foundation,
Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
-->

cl-skkservは既定値を設定するために`data/`ディレクトリに辞書ファイルがない場合は、openlabから`SKK-JISYO.L`がダウンロードされます。

```lisp
(defvar jisyo (merge-pathnames #p"data/SKK-JISYO.L" (component-pathname (find-system :cl-skkserv))))
(unless (probe-file jisyo)
  (download "http://openlab.ring.gr.jp/skk/skk/dic/SKK-JISYO.L" jisyo))
```

設定ファイルが読み込まれない場合の既定値は以下の通りです。

```lisp
(defparameter *dictionary* (make-instance 'skk-dictionary :pathname jisyo))
(defparameter *address* "localhost")
(defparameter *port* 1178)
(defparameter *encoding* :eucjp)
```

## 設定ファイルの書き方

`~/.skkservrc`内で`skkserv-user`パッケージに入り作業します。

起動時に読み込まれます。動作に影響を与える変数は以下の通りです。

- `*dictionary*`
- `*address*`
- `*port*`
- `*encoding*`

これらを`setq`等で変更することで動作を変えることが出来ます。
次は設定ファイルの一例です。


```
(in-package :skkserv-user)
(defvar base
  (make-instance 'skk-dictionary :pathname #p"/path/to/dictionary"))
(defvar additional
  (make-instance 'google-ime-dictionary))
(setq *dictionary*
      (make-instance 'mixed-dictionary :dictionaries (list base additional)))
(setq *port* 1178)
(setq *encoding* :eucjp)
```
