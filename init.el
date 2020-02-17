;; init.el -*- lexical-binding: t; -*-
;; Requires: Emacs 26+

;;----------------------------------------------------------------------------
;; GC Config
;;----------------------------------------------------------------------------

;; Set GC threshold to a large value during init
(defconst gc-default-threshold gc-cons-threshold)
(setq gc-cons-threshold (* gc-default-threshold 100))

;;----------------------------------------------------------------------------
;; Base Initialization
;;----------------------------------------------------------------------------

;; Initialize package management and custom variables
(setq custom-file "~/.emacs.d/init-package.el")
(load custom-file)

;; Enable delete selection mode
(delete-selection-mode)

;; Disable tool bar, scroll bar and menu bar
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(scroll-bar-mode -1)
(menu-bar-mode -1)

;; More extensive apropos searches
(setq apropos-do-all t)

;; Show column number
(column-number-mode)

;; Customize scratch buffer
(setq initial-scratch-message nil)
(setq initial-major-mode 'fundamental-mode)

;; IDO
(ido-mode)
(setq ido-everywhere t)
(setq ido-enable-flex-matching t)
(setq ido-default-buffer-method 'selected-window)
(setq ido-separator "\n")
(setq ido-ignore-buffers
      '("^ "
	"*Completions*"
	"*Shell Command Output*"
	"*Flymake log*"
	"*Compile-Log*"
	"magit-process*"
	"magit-revision*"
	"magit-reflog*"))

;; Activate side scroll
(put 'scroll-left 'disabled nil)
(put 'scroll-right 'disabled nil)
(set-default 'truncate-lines t)

;; Maximize at start
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Move backup and autosave to /tmp
(setq backup-directory-alist `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))

;; Show matching parenthesis
(show-paren-mode)

;; Insert matching parenthesis
(electric-pair-mode)

;; Indent automatically on RET
(electric-indent-mode)

;; Save position in buffer
(save-place-mode)

;; Visual line mode when editing Markdown files
(add-hook 'markdown-mode-hook 'visual-line-mode)

;; Dired
(setq dired-listing-switches "-alhv --group-directories-first")
(setq dired-auto-revert-buffer t)

;; Dired-x
(require 'dired-x)

;; Set up uniquify
(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)

;; Highlight long lines in python-mode
(require 'whitespace)
(setq-default whitespace-style '(face tabs lines-tail trailing)
	      whitespace-line-column 88)

(add-hook 'python-mode-hook 'whitespace-mode)

;; Set fill-column for Python
(add-hook 'python-mode-hook (lambda () (set-fill-column 79)))

;; Make frame title nicer
(setq frame-title-format (format "%%b - GNU Emacs %s" emacs-version))

;; Enable auto revert
(global-auto-revert-mode)

;; TRAMP
;; Use C-x C-f /ssh:etc...
(require 'tramp)
(setq tramp-default-method "ssh")
(tramp-set-completion-function "ssh" '((tramp-parse-sconfig "~/.ssh/config")))

;; Registers
(setq register-preview-delay 0)

(defun my-register-preview-function (r)
  "A custom register-previewing function which tries to be more legible."
  (format " %s  %s\n"
	  (propertize (single-key-description (car r)) 'face '(:foreground "deep pink"))
	  (register-describe-oneline (car r))))

(setq register-preview-function #'my-register-preview-function)

;; Make scrolling quicker
(setq auto-window-vscroll nil)

;; Dont jump when scrolling by line
(setq scroll-conservatively 10)

;; Load per-PC configuration file
;; local.el is gitignore'd
(load "~/.emacs.d/local.el" t t)

;; secret values
(load "~/Dropbox/emacs/secrets.el" t t)

;; Start Emacs server
;; This allows using emacsclient as an editor
(server-start)

;; Print yank pointer index after yank-pop
(advice-add 'yank-pop :after
	    (lambda (&rest r)
	      (unless (window-minibuffer-p)
		(let* ((ring-len (length kill-ring))
		       (pos (+ (- ring-len
				  (length kill-ring-yank-pointer))
			       1)))
		  (message "Yanked element %d of %d" pos ring-len)))))

;; Deactivate mark before undo (never do selective undo in region)
(advice-add 'undo :before (lambda (&rest r) (deactivate-mark)))

;; In shell mode, don't jump to position after output
(add-hook 'shell-mode-hook
	  (lambda ()
	    (remove-hook 'comint-output-filter-functions
			 'comint-postoutput-scroll-to-bottom)))

;; Ignore duplicate commands in shell mode
(setq comint-input-ignoredups t)

;; Load iso-transl in order to change the C-x 8 prefix later
(require 'iso-transl)

;; Load python-mode in order to change keymap later
(require 'python)

;; Create templates using tempo.el
(require 'tempo)

;; Tempo templates for Python

(tempo-define-template "python-pdb"
		       '("import pdb; pdb.set_trace()")
		       "pdb")

(tempo-define-template "python-code-interact"
		       '("import code; code.interact(local=locals())")
		       "interact")

(tempo-define-template "python-pprint"
		       '("from pprint import pprint" n>
			 "pprint(" (P "Expression: ") ")")
		       "pprint")

(tempo-define-template "python-traceback"
		       '("import traceback; traceback.print_stack()")
		       "traceback")

;; Allow hippie-expand to complete tempo tags
(defun try-tempo-complete-tag (old)
  (unless old
    (tempo-complete-tag)))

(add-to-list 'hippie-expand-try-functions-list 'try-tempo-complete-tag)

;; JS indent level
(setq js-indent-level 4)

;; Configure Gnus
(setq gnus-thread-sort-functions
      '(gnus-thread-sort-by-number
        gnus-thread-sort-by-most-recent-date))

(setq gnus-subthread-sort-functions
      '(gnus-thread-sort-by-number
        (not gnus-thread-sort-by-most-recent-date)))

;; Enable mails search (from https://www.emacswiki.org/emacs/GnusGmail#toc22)
(with-eval-after-load 'gnus
  (require 'nnir))

;; Always confirm quit
(setq confirm-kill-emacs 'yes-or-no-p)

;; Spell-check messages
(add-hook 'message-mode-hook 'flyspell-mode)

;; Always save bookmarks
(setq bookmark-save-flag 1)

;; Ignore case in autocomplete
(setq completion-ignore-case t)

;; Disable VC mode
(setq vc-handled-backends nil)

;; Add a newline at the end of file on save
(setq require-final-newline t)

;; Setup stuff on macOS
(when (eq system-type 'darwin)
  ;; Change behavior of left command key
  (setq mac-command-modifier 'meta)

  ;; Fix dired not working
  (require 'ls-lisp)
  (setq ls-lisp-dirs-first t
	ls-lisp-use-insert-directory-program nil)
  (setq dired-listing-switches "-alhv")

  ;; Add brew binaries to PATH
  (setenv "PATH" (concat (getenv "PATH") ":/usr/local/bin"))
  (add-to-list 'exec-path "/usr/local/bin")

  ;; Disable bell
  (setq ring-bell-function 'ignore)

  ;; Setup ispell
  (setq ispell-program-name "/usr/local/bin/aspell")

  ;; Fix GPG problem
  (setq epa-pinentry-mode 'loopback))

;;----------------------------------------------------------------------------
;; Org Mode
;;----------------------------------------------------------------------------

;; Configure directories
(setq org-directory "~/Dropbox/org/")
(setq org-agenda-files (list org-directory))

;; Quick capture file
(setq org-default-notes-file (concat org-directory "/notes.org"))

;; TODO lists states, last state used as 'done'
(setq org-todo-keywords '((sequence "TODO" "CURRENT" "DONE")))

;; important tag
(setq org-tag-faces '(("imp" . (:foreground "red" :weight bold))
		      ("easy" . (:foreground "green"))))

;; Configure Babel
(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)
   (emacs-lisp . t)
   (shell . t)
   (verb . t)))

(setq org-confirm-babel-evaluate nil)

;; Refile to any agenda file
(setq org-refile-targets '((org-agenda-files :maxlevel . 2)))

;; Save all Org buffers after refile
(advice-add 'org-refile :after (lambda (&rest r) (org-save-all-org-buffers)))

;; Always refile to top of entry
(setq org-reverse-note-order t)

;; Don't allow TODOs to be completed unless all children tasks are marked as done
(setq org-enforce-todo-dependencies t)

;; Record time and not when TODOs are completed
(setq org-log-done 'note)

;; Don't repeat date when note is added ("NOTE CLOSED %t")
(setf (cdr (assq 'done org-log-note-headings)) "NOTE:")

;; Align tags further right
(setq org-tags-column 85)

;;----------------------------------------------------------------------------
;; Package Initialization
;;----------------------------------------------------------------------------

;; Set theme, but make comments a bit brighter (original value: #75715E)
(setq monokai-comments "#908E80")
(load-theme 'monokai t)

;; Projectile
(projectile-mode)

(setq projectile-mode-line-function
      (lambda ()
	(format " P[%s]" (projectile-project-name))))

(setq projectile-use-git-grep t)

;; Magit
(with-eval-after-load 'magit
  ;; Always confirm with yes/no when discarding changes
  (setq magit-slow-confirm t)

  ;; Remove ":" from magit buffer names to search them more easily
  (setq magit-buffer-name-format
	(replace-regexp-in-string ":" "" magit-buffer-name-format)))

;; Company
(add-hook 'after-init-hook 'global-company-mode)

;; flymake-shellcheck
(add-hook 'sh-mode-hook 'flymake-shellcheck-load)

;; YAML mode
(add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))

;; Avy
(setq avy-all-windows nil)
(setq avy-background t)
(setq avy-style 'words)

;; Elpy
(elpy-enable)

;; Set default env name for pyvenv
(setq pyvenv-default-virtual-env-name "env")

;; Install Python tools in currently active venv
(setq elpy-rpc-virtualenv-path 'current)

;; Configure Verb package
(setq verb-auto-kill-response-buffers t)

(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-c C-r") verb-command-map))

;;----------------------------------------------------------------------------
;; Custom Functions
;;----------------------------------------------------------------------------

(defun move-line-up ()
  "Move current line up."
  (interactive)
  (when (> (line-number-at-pos) 1)
    (let ((col (current-column)))
      (transpose-lines 1)
      (previous-line)
      (previous-line)
      (move-to-column col))))

(defun move-line-down ()
  "Move current line down."
  (interactive)
  (when (< (line-number-at-pos) (count-lines (point-min) (point-max)))
    (let ((col (current-column)))
      (next-line)
      (transpose-lines 1)
      (previous-line)
      (move-to-column col))))

(defun backward-delete-word ()
  "Delete a word backwards. Delete text from previous line only when
current line is empty. This behaviour is similar to the one used by
SublimeText/Atom/VSCode/etc."
  (interactive)
  (if (= 0 (current-column))
      (call-interactively #'backward-delete-char-untabify)
    (let ((point-after-bw (save-excursion (backward-word) (point))))
      (if (< (count-lines 1 point-after-bw) (count-lines 1 (point)))
	  (delete-region (line-beginning-position) (point))
	(delete-region (point) point-after-bw)))))

(defun delete-whole-line ()
  "Delete current line."
  (interactive)
  (goto-char (line-beginning-position))
  (delete-region (point) (line-end-position))
  (delete-forward-char 1))

(defun edit-init ()
  "Edit init.el in a buffer."
  (interactive)
  (find-file "~/.emacs.d/init.el"))

(defun duplicate-line ()
  "Duplicate a line, and move point to it (maintain current column)."
  (interactive)
  (let ((val (buffer-substring (line-beginning-position) (line-end-position))))
    (save-excursion
      (move-end-of-line 1)
      (newline)
      (insert val)))
  (next-line))

(defun dired-org-agenda ()
  "Open org-directory with dired."
  (interactive)
  (dired org-directory "-l")
  (dired-hide-details-mode))

(defun print-buffer-file-name (&optional arg)
  "Print the current buffer's file path.
If ARG is non-nil, make the file path the latest kill in the kill
ring."
  (interactive "P")
  (let ((name (buffer-file-name)))
    (unless name
      (user-error "Buffer is not visiting any file"))
    (message name)
    (when arg
      (kill-new name))))

(defun rename-file-buffer ()
  "Rename the current buffer's file, and the buffer itself to match
the new file name."
  (interactive)
  (let ((current-file-name (buffer-file-name)))
    (unless current-file-name
      (user-error "Current buffer is not visiting any file"))
    (when (buffer-modified-p)
      (user-error "Current buffer has unsaved changes"))
    (let ((new-file-name (read-file-name "New file name:" nil current-file-name 'confirm)))
      (when (or (file-exists-p new-file-name)
		(get-file-buffer new-file-name))
	(user-error "File already exists!"))
      (rename-file current-file-name new-file-name)
      (set-visited-file-name new-file-name)
      (let ((inhibit-message t))
	(save-buffer)))))

(defun wrap-region (c)
  "Wrap point or active region with character C and its corresponding
pair."
  (interactive (list (read-char-exclusive "Wrap region with: ")))
  (let* ((char-pairs '(("{" . "}")
		       ("(" . ")")
		       ("[" . "]")
		       ("<" . ">")
		       ("¿" . "?")
		       ("¡" . "!")))
	 (s (char-to-string c))
	 (pair (catch 'loop
		 (dolist (p char-pairs)
		   (when (or (string= s (car p))
			     (string= s (cdr p)))
		     (throw 'loop p)))
		 (cons s s))))
    (if (use-region-p)
	(let ((region-end-pos (region-end)))
	  (insert-pair nil (car pair) (cdr pair))
	  (goto-char (+ region-end-pos 2)))
      (insert (car pair) (cdr pair))
      (backward-char))))

(defun kill-ring-save-whole-buffer ()
  "Save the entire buffer as if killed, but don't kill it."
  (interactive)
  (kill-ring-save (point-min) (point-max))
  (message "Buffer copied to kill ring"))

(defun json-pretty-print-dwim ()
  "Prettify JSON in region if it is active, otherwise on whole buffer."
  (interactive)
  (let ((json-encoding-default-indentation (make-string js-indent-level ? )))
    (if (use-region-p)
	(json-pretty-print (region-beginning) (region-end))
      (json-pretty-print-buffer))))

(defun goto-last-edit ()
  "Go to the last edit made in the current buffer."
  (interactive)
  (unless (or (consp buffer-undo-list)
	      (not buffer-undo-list))
    (user-error "Can't go to last edit: invalid undo list"))
  (let ((pos (catch 'loop
	       (dolist (item buffer-undo-list)
		 (when (and (consp item)
			    (or (integerp (car item))
				(stringp (car item))))
		   (throw 'loop (abs (cdr item))))))))
    (unless (or (null pos)
		(= (point) pos))
      (push-mark)
      (goto-char pos))))

(defun goto-end-clear-screen ()
  "Go to the end of the buffer and then move current buffer line to
window line 0."
  (interactive)
  (end-of-buffer '(4))
  (recenter-top-bottom 0))

(define-derived-mode long-lines-mode fundamental-mode "Long-Lines"
  "Simple mode to allow editing files with very long lines."
  (setq bidi-display-reordering nil)
  (buffer-disable-undo))

(defun open-file-external (filename)
  "Open file or directory FILENAME using the user's preferred
application."
  (interactive "G")
  (let ((executable (if (eq system-type 'darwin) "open" "xdg-open")))
    (unless (executable-find executable)
      (user-error (format "Could not find the %s executable" executable)))
    (unless (file-exists-p filename)
      (user-error "Invalid file path"))
    (call-process executable nil nil nil (file-truename filename))))

(defun describe-original-key (key)
  "Display documentation of the function invoked by KEY, when using
Emacs' original keybindings."
  (interactive "sKey: ")
  (message "%s"
	   (shell-command-to-string
	    (format "emacs -Q --batch --eval '(describe-key-briefly (kbd \"%s\"))'"
		    key))))

(defun lock-screen ()
  "Lock the OS screen."
  (interactive)
  (if (eq system-type 'darwin)
      (call-process "pmset" nil nil nil "displaysleepnow")
    (call-process "gnome-screensaver-command" nil nil nil "--lock")))

;;----------------------------------------------------------------------------
;; Keybindings
;;----------------------------------------------------------------------------

(global-set-key (kbd "C-x g") 'magit-status)
(global-set-key (kbd "C-x s") 'save-buffer)
(global-set-key (kbd "C-x C-d") 'dired-jump)

(global-set-key (kbd "C-h a") 'apropos)
(global-set-key (kbd "C-o") 'flymake-goto-next-error)
(global-set-key (kbd "C-j") 'avy-goto-char-timer)
(global-set-key (kbd "C-;") 'comment-line)
(global-set-key (kbd "C-<") 'scroll-right)
(global-set-key (kbd "C->") 'scroll-left)
(global-set-key (kbd "C-<backspace>") 'backward-delete-word)
(global-set-key (kbd "C-S-<backspace>") 'delete-whole-line)
(global-set-key (kbd "C-M-#") 'wrap-region)
(global-set-key (kbd "C-M-_") 'negative-argument)

(global-set-key (kbd "M-_") 'negative-argument)
(global-set-key (kbd "M-l") 'switch-to-buffer)
(global-set-key (kbd "M-o") 'other-window)
(global-set-key (kbd "M-<up>") 'move-line-up)
(global-set-key (kbd "M-<down>") 'move-line-down)
(global-set-key (kbd "M-n") 'forward-paragraph)
(global-set-key (kbd "M-p") 'backward-paragraph)
(global-set-key (kbd "M-i") 'imenu)
(global-set-key (kbd "M-j") 'mode-line-other-buffer)
(global-set-key (kbd "M-<backspace>") 'goto-last-edit)
(when (eq system-type 'darwin)
  (global-set-key (kbd "M-`") 'other-frame))

(global-set-key (kbd "C-c d") 'duplicate-line)
(global-set-key (kbd "C-c f") 'flymake-mode)
(global-set-key (kbd "C-c c") 'projectile-find-file)
(global-set-key (kbd "C-c k") 'kill-current-buffer)
(global-set-key (kbd "C-c j") 'json-pretty-print-dwim)
(global-set-key (kbd "C-c i") 'indent-region)
(global-set-key (kbd "C-c e i") 'edit-init)
(global-set-key (kbd "C-c e r") 'rename-file-buffer)
(global-set-key (kbd "C-c e d") 'debbugs-gnu)
(global-set-key (kbd "C-c e p") 'print-buffer-file-name)
(global-set-key (kbd "C-c e o") 'open-file-external)
(global-set-key (kbd "C-c e l") 'lock-screen)
(global-set-key (kbd "C-c q") 'quick-calc)
(global-set-key (kbd "C-c m") 'kill-ring-save-whole-buffer)
(global-set-key (kbd "C-c o a") 'org-agenda)
(global-set-key (kbd "C-c o d") 'dired-org-agenda)
(global-set-key (kbd "C-c s SPC") 'spotify-playpause)
(global-set-key (kbd "C-c s s") 'spotify-next)
(global-set-key (kbd "C-c s p") 'spotify-previous)
(global-set-key (kbd "C-c s c") 'spotify-current)

(global-set-key (kbd "ESC ESC ESC") 'keyboard-quit)
(global-set-key [remap dabbrev-expand] 'hippie-expand)

(define-key global-map (kbd "M-'") iso-transl-ctl-x-8-map)

(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
(define-key shell-mode-map (kbd "C-r") 'comint-history-isearch-backward-regexp)
(define-key shell-mode-map (kbd "C-l") 'goto-end-clear-screen)
(define-key elpy-mode-map (kbd "C-c y t") 'elpy-test-pytest-runner)
(define-key elpy-mode-map (kbd "C-c y b") 'elpy-black-fix-code)
(define-key python-mode-map (kbd "M-[") 'python-indent-shift-left)
(define-key python-mode-map (kbd "M-]") 'python-indent-shift-right)

(define-key org-mode-map (kbd "M-n") 'outline-next-visible-heading)
(define-key org-mode-map (kbd "M-p") 'outline-previous-visible-heading)
(define-key org-mode-map (kbd "C-j") 'avy-goto-char-timer)
(define-key org-mode-map (kbd "C-c o r") 'org-archive-to-archive-sibling)
(define-key org-mode-map (kbd "C-c o t") 'org-force-cycle-archived)

;;----------------------------------------------------------------------------
;; Remove default keybindings
;;----------------------------------------------------------------------------

;; Disable some default keys that get hit by accident
(global-unset-key (kbd "C-x f"))
(global-unset-key (kbd "C-x C-n"))
(global-unset-key (kbd "M-;"))
(global-unset-key (kbd "M-k"))
(global-unset-key (kbd "M-t"))
(global-unset-key (kbd "C-z"))
(global-unset-key (kbd "C-t"))

(define-key org-mode-map (kbd "C-c [") nil)
(define-key org-mode-map (kbd "C-'") nil)
(define-key elpy-mode-map (kbd "C-c C-c") nil)
(define-key elpy-mode-map (kbd "<C-return>") nil)
(define-key python-mode-map (kbd "C-c C-c") nil)
(define-key c-mode-map (kbd "M-j") nil)

;;----------------------------------------------------------------------------
;; Cleanup
;;----------------------------------------------------------------------------

;; Restore GC threshold
(setq gc-cons-threshold gc-default-threshold)
