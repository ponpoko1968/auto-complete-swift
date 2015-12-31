;; Copyright (C) 2015  Shuji OCHI
;; Author: Shuji OCHI <ponpoko1968@gmail.com>
;; Keywords:


(require 'json)

(eval-when-compile (require 'cl))
(defvar swift-executable "/usr/local/bin/sourcekitten")
(defvar swift-compiler-args "-sdk /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk")

(defun swift-process-exec (command)
  (with-output-to-string
    (with-current-buffer standard-output
      (apply 'call-process (car command) nil t nil (cdr command)))))

(defun swift-process (buffer point)
  (unless (buffer-file-name buffer)
    (return ""))
  (let* ((filename (buffer-file-name buffer))
         (p point)
         (col (1+ (- point (point-at-bol))))
         (row (count-lines point (point-min)))
         (cmd (list swift-executable "complete"
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
         (candidates (json-read-from-string string)))
    (mapcar (lambda (candidate)
              (let* ((name (cdr (assoc "name" candidate)))
                     (typeName (cdr (assoc "typeName" candidate))))
                (popup-make-item name
                                 :symbol typeName
                                 :summary typeName))) candidates)))

(defvar ac-source-swift-complete
  '((candidates . (swift-get-completions nil ac-point))
    (prefix "[^a-zA-Z0-9_]\\(\\(?:[a-zA-Z_][a-zA-Z0-9_]*\\)?\\)" nil 1)
    (requires . 0)
    (symbol . "C")))

(defun ac-complete-swift ()
  (interactive)
  (auto-complete '(ac-source-swift-complete)))

(provide 'auto-complete-swift)
