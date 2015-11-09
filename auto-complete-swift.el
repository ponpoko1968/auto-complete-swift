;; Copyright (C) 2015  Shuji OCHI
;; Author: Shuji OCHI <ponpoko1968@gmail.com>
;; Keywords:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

(require 'json)

(eval-when-compile (require 'cl))
(defvar swift-executable "/usr/local/bin/sourcekitten")
(defvar swift-compiler-args "-sdk /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.11.sdk")

(defun swift-process-exec (command)
  (with-output-to-string
    (with-current-buffer standard-output
      (apply 'call-process (car command) nil '(t ".swift-error") nil (cdr command)) )))

(defun swift-process (buffer point)
  (unless (buffer-file-name buffer)
    (return ""))
  (let* ((filename (buffer-file-name buffer))
         (p      (1+ (- point (point-at-bol))))
         (col      (1+ (- point (point-at-bol))))
         (row      (count-lines point (point-min)))
         (cmd      (list swift-executable "complete"
                         "--file" filename "--offset" (format "%s" p) "--compilerargs" "--" swift-compiler-args) ))
    (message (format "complete at %s:%s:%s" filename row col))
    (swift-process-exec cmd)))

(defun swift-get-completions (&optional buffer point)
  ;; save all modified buffers
  (or buffer (setq buffer (current-buffer)))
  (or point (setq point (point)))
  (save-some-buffers t)
  (let* ((output (swift-process buffer point)))
    (swift-get-process-completion-result output)))

(defun swift-get-process-completion-result (string)
  (let* ((json-array-type 'list)
         (json-key-type 'string)
         (candidates (json-read-from-string string)) )
    (mapcar (lambda (candidate)
              
              (cdr (assoc  "name" candidate))) candidates)))



(defvar ac-source-swift-complete
  '((candidates . (swift-get-completions nil ac-point))
    (prefix "[^a-zA-Z0-9_]\\(\\(?:[a-zA-Z_][a-zA-Z0-9_]*\\)?\\)" nil 1)
    (requires . 0)
    (symbol . "C")
    ))


(defun ac-complete-swift ()
  (interactive)
  (auto-complete '(ac-source-swift-complete)))

(provide 'auto-complete-swift)
