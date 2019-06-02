;;; cli-docs.el --- Chinese docs of some cli tools  -*- lexical-binding: t; -*-

;; Copyright (C) 2019  Xu Chunyang

;; Author: Xu Chunyang <mail@xuchunyang.me>
;; Homepage: https://github.com/xuchunyang/cli-docs.el
;; Package-Requires: ((emacs "25"))
;; Created: 2019-05-27T22:03:36+08:00
;; Keywords: docs
;; Version: 0

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Look up Chinese docs of some cli commands.
;;
;; See https://github.com/xuchunyang/cli-docs.el for more info.

;;; Code:

(require 'seq)
(require 'json)

(defvar url-http-end-of-headers)
(defvar url-http-response-status)

(defconst cli-docs-index-url "https://unpkg.com/linux-command/dist/data.json"
  "URL of the index.")

(defconst cli-docs-command-url "https://unpkg.com/linux-command/command/%s.md"
  "URL template of the command.")

(defgroup cli-docs nil
  "Chinese docs of some cli tools."
  :link '(url-link "https://github.com/xuchunyang/cli-docs.el")
  :group 'help)

(defcustom cli-docs-directory (expand-file-name
                               "cli-docs/"
                               (seq-find #'file-exists-p
                                         (list (locate-user-emacs-file "var/")
                                               user-emacs-directory)))
  "Directory where data files will be saved."
  :group 'cli-docs
  :type 'directory)

;;;###autoload
(defun cli-docs-update-cache ()
  "Update caches."
  (interactive)
  (let* ((files (directory-files cli-docs-directory nil (rx ".md" eos)))
         (commands (mapcar #'file-name-sans-extension files)))
    (cl-loop for command in commands
             for i from 1
             for url = (format cli-docs-command-url command)
             for filename = (expand-file-name (concat command ".md") cli-docs-directory)
             do (let ((url-show-status nil))
                  (message "[%d/%d] Fetching %s..." i (length commands) url)
                  (url-copy-file url filename t)))))

(defvar cli-docs-index nil
  "A list of (NAME . DESCRIPTION).")

(defun cli-docs-index ()
  "Set and return value of the variable `cli-docs-index'."
  (unless cli-docs-index
    (setq cli-docs-index
          (with-current-buffer (url-retrieve-synchronously cli-docs-index-url)
            (unless (= url-http-response-status 200)
              (error "url request failed: %s\n\n%s" url-http-response-status
                     (buffer-string)))
            (set-buffer-multibyte t)
            ;; `url-http-end-of-headers' doesn't work well while caching
            (goto-char (point-min))
            (re-search-forward "\n\n")
            (mapcar (lambda (x)
                      (cons (symbol-name (car x))
                            (alist-get 'd (cdr x))))
                    (json-read)))))
  cli-docs-index)

(defun cli-docs--read-command ()
  (let* ((commands (mapcar #'car (cli-docs-index)))
         (guess (thing-at-point 'symbol))
         (default (and guess (downcase guess)))
         (prompt (if (member default commands)
                     (format "Command (default %s): " guess)
                   "Command: "))
         (completion-ignore-case t))
    (completing-read prompt commands nil t nil nil default)))

;;;###autoload
(defun cli-docs (command)
  "View the docs of COMMAND."
  (interactive (list (cli-docs--read-command)))
  (let ((filename (expand-file-name (concat command ".md") cli-docs-directory)))
    (unless (file-exists-p filename)
      (make-directory (file-name-directory filename) t)
      (url-copy-file (format cli-docs-command-url command) filename))
    (view-file filename)))

(declare-function helm "helm" (&rest plist))
(declare-function helm-build-sync-source "helm-source" (name &rest args))

;;;###autoload
(defun cli-docs-helm ()
  "Helm interface for `cli-docs'"
  (interactive)
  (require 'helm)
  (let* ((candidates (mapcar
                      (lambda (x)
                        (pcase-exhaustive x
                          (`(,name . ,description)
                           ;; (apply #'max (mapcar #'length (mapcar #'car cli-docs-index)))
                           ;; => 17
                           (cons (format "%-17s  %s" name description)
                                 name))))
                      (cli-docs-index)))
         (guess (thing-at-point 'symbol))
         (guess (and guess (downcase guess)))
         (input (and guess (rassoc guess candidates) guess)))
    (helm :sources (helm-build-sync-source "Commands"
                     :candidates candidates
                     :action #'cli-docs)
          :input input
          :buffer "*helm CLI Commands*")))

(provide 'cli-docs)
;;; cli-docs.el ends here
