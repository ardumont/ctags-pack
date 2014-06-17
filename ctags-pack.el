;;; ctags-pack.el --- Deal with tags

;;; Commentary:

;;; Code:

(require 'install-packages-pack)
(install-packs '(;; need org2blog as a glue between org-mode and wordpress
                 ctags
                 etags-select))

(require 'ctags)
(require 'etags-select)

(defvar *CTAGS-BINARY* "ctags-exuberant"
  "Ctags binary to use for ctags generation.")

(defvar *CTAGS-LOG-PREFIX* "ctags-pack - "
  "Prefix log message to explicit what triggers the TAGS.")

;; When a new file is found in a git repo, set the project tags filename.
(add-hook 'find-file-hook 'set-project-tags-file-name)

;; When a new file is found in a git repo, generate the project tags file if it
;; doesn't exist.
;;(add-hook 'find-file-hook 'generate-project-tags-if-missing)

;; When a file is saved, (potentially) regenerate the tags file.
(add-hook 'after-save-hook 'regenerate-project-tags)

;; If the tags file is rewritten, pick up the changes without prompting.
(setq tags-revert-without-query t)

;; Always add tables to tags-table-list
(setq tags-add-tables t)

;; Use etags-select-find-tag-at-point on M-.
(global-set-key "\M-." 'etags-select-find-tag-at-point)
;;; ctags-pack.el ends here
