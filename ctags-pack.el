;;; ctags-pack.el --- Deal with tags

;;; Commentary:

;;; Code:

(require 'install-packages-pack)
(install-packs '(magit
                 etags-select))

(require 'etags)
(require 'etags-select)
(require 'magit)

(defvar *CTAGS-BINARY* "ctags-exuberant"
  "Ctags binary to use for ctags generation.")

(defvar *CTAGS-LOG-PREFIX* "ctags-pack - "
  "Prefix log message to explicit what triggers the TAGS.")

(defun ctags-pack/msg (log)
  "Log LOG message."
  (message "%s%s" *CTAGS-LOG-PREFIX* log))

(defun ctags-pack/set-project-tags-file-name ()
  "If the current directory is a git project (and not the home directory).
Make .tags the default tag file location.
You probably want to add .tags to a .gitignore_global file."
  (interactive)
  (let* ((top-dir   (magit-get-top-dir))
         (home-dir  (expand-file-name "~/"))
         (tags-file (format "%sTAGS" top-dir)))
    (when (and top-dir
               (not (string-equal top-dir home-dir)))
      (setq-local tags-table-list (list tags-file))
      (ctags-pack/msg (format "Project tags file set to: %s" tags-file))
      (ctags-pack/generate-project-tags-if-missing))))

(defun ctags-pack/generate-project-tags (tags-file)
  "Generate tags for current project in `TAGS-FILE`."
  (interactive)
  (call-process *CTAGS-BINARY* nil nil nil
                  "-Re"
                  "--exclude=.git"
                  "--exclude='.#*'"
                  "--langmap=Lisp:+.clj.cljs"
                  (format "-f %s" tags-file)
                  (magit-get-top-dir)))

(defun ctags-pack/get-project-tags-file-name ()
  "Get file name to put project tags in."
  (interactive)
  (car tags-table-list))

(defun ctags-pack/generate-project-tags-if-missing ()
  "If `tags-table-list` is set and no project tags file exists, generate it."
  (interactive)
  (when tags-table-list
    (let* ((tags-file (ctags-pack/get-project-tags-file-name)))
      (when (and tags-file (not (file-exists-p tags-file)))
        (ctags-pack/generate-project-tags tags-file)
        (ctags-pack/msg (format "Generated new project tags in %s" tags-file))))))

(defun ctags-pack/regenerate-project-tags ()
  "If `tags-file-name` is set, regenerate the tags file."
  (interactive)
  (let* ((tags-file-name (ctags-pack/get-project-tags-file-name)))
    (when tags-file-name
      (ctags-pack/generate-project-tags tags-file-name)
      (ctags-pack/msg (format "Regenerated project tags in %s" tags-file-name)))))

;; When a new file is found in a git repo, set the project tags filename.
(add-hook 'find-file-hook 'ctags-pack/set-project-tags-file-name)

;; When a new file is found in a git repo, generate the project tags file if it
;; doesn't exist.
;;(add-hook 'find-file-hook 'ctags-pack/generate-project-tags-if-missing)

;; When a file is saved, (potentially) regenerate the tags file.
(add-hook 'after-save-hook 'ctags-pack/regenerate-project-tags)

;; If the tags file is rewritten, pick up the changes without prompting.
(setq tags-revert-without-query t)

;; Always add tables to tags-table-list
(setq tags-add-tables t)

;; Use etags-select-find-tag-at-point on M-.
(global-set-key "\M-." 'etags-select-find-tag-at-point)

(provide 'ctags-pack)
;;; ctags-pack.el ends here
