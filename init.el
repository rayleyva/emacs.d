;; init.el -*- lexical-binding: t; -*-
;; Requires: Emacs 26+

;;----------------------------------------------------------------------------
;; Emacs General Config
;;----------------------------------------------------------------------------

;; Configure GC
(defconst gc-default-threshold 800000)
(defconst gc-large-threshold (* gc-default-threshold 10))

;; Set GC threshold to a large value during init
(setq gc-cons-threshold gc-large-threshold)

;; Configure package sources
(require 'package)
(setq package-archives
      '(("gnu" . "http://elpa.gnu.org/packages/")
	("marmalade" . "http://marmalade-repo.org/packages/")
	("melpa" . "https://melpa.org/packages/")))

;; Call package-initialize on version 26 only
(when (< emacs-major-version 27)
  (package-initialize))

;; Customize
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

;; Disable tool bar, scroll bar and menu bar
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(scroll-bar-mode -1)
(menu-bar-mode -1)

;; Sort help by relevance
(setq apropos-sort-by-scores t)
(setq apropos-do-all t)

;; Disable welcome screen
(setq inhibit-startup-screen t)

;; Show column number
(column-number-mode t)

;; Customize scratch buffer
(setq initial-scratch-message nil)
(setq initial-major-mode 'fundamental-mode)

;; IDO
(ido-mode 1)
(setq ido-everywhere t)
(setq ido-enable-flex-matching t)
(setq ido-separator "\n")
(setq ido-ignore-buffers
      '("^ "
	"*Completions*"
	"*Shell Command Output*"
	"*Messages*"
	"*Flymake log*"
	"*Compile-Log*"
	"*Help*"
	"magit-process"
	"magit-diff"))

;; Move between windows using S-<left> S-<right> etc.
(windmove-default-keybindings)

;; Set theme
(load-theme 'monokai t)

;; Activate side scroll
(put 'scroll-left 'disabled nil)
(put 'scroll-right 'disabled nil)
(set-default 'truncate-lines t)

;; Maximize at start
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Move backup and autosave to /tmp
(setq backup-directory-alist `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))

;; Highlight current line
(global-hl-line-mode +1)
(set-face-attribute hl-line-face nil :underline nil)

;; Show matching parenthesis
(show-paren-mode 1)

;; Insert matching parenthesis
(electric-pair-mode 1)

;; Indent automatically on RET
(electric-indent-mode 1)

;; Save position in buffer
(save-place-mode 1)

;; Smaller cursor
(setq-default cursor-type 'bar)

;; Save/load desktop automatically
(desktop-save-mode 1)
(setq desktop-restore-eager 2)
(setq desktop-save t)

;; Disable truncate-lines when editing Markdown files
(add-hook 'markdown-mode-hook 'visual-line-mode)

;; Dired
(setq dired-listing-switches "-alh")
(setq dired-auto-revert-buffer t)

;; Set up uniquify
(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)

;; Shrink left fringe
(fringe-mode '(2 . nil))

;; Highlight long lines in python-mode
(require 'whitespace)
(setq-default whitespace-style '(face empty tabs lines-tail trailing spaces)
	      whitespace-line-column 79)
(add-hook 'python-mode-hook #'whitespace-mode)

;; Set fill-column for Python
(add-hook 'python-mode-hook (lambda () (set-fill-column 79)))

;; Make frame title nicer
(setq frame-title-format (format "%%b - Emacs %s" emacs-version))

;; Set ibuffer groups
(setq ibuffer-saved-filter-groups
      (quote (("default"
	       ("Python" (mode . python-mode))
	       ("REST" (mode . restclient-mode))
	       ("Shell" (mode . shell-mode))
	       ("Dired" (mode . dired-mode))
	       ("Emacs Lisp" (mode . emacs-lisp-mode))
	       ("Git" (name . "^magit"))
	       ("JSON" (name . "\\.json\\'"))
	       ("Org" (or (name . "\\.org\\'")
			  (mode . org-mode)
			  (mode . org-agenda-mode)))))))

(add-hook 'ibuffer-mode-hook
	  (lambda ()
	    (ibuffer-switch-to-saved-filter-groups "default")))

;; Enable auto revert
(global-auto-revert-mode)

;; Hi-Lock mode
(global-hi-lock-mode 1)

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

;; Allow auto-resizing windows horizontally on command
(setq fit-window-to-buffer-horizontally t)

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
		  (message "Yanked element %d of %d." pos ring-len)))))

;; When scrolling by page, leave 1 line of continuity instead of 2
(setq next-screen-context-lines 1)

;; In shell mode, don't jump to position after output
(add-hook 'shell-mode-hook
	  (lambda ()
	    (remove-hook 'comint-output-filter-functions 'comint-postoutput-scroll-to-bottom)))

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
(setq org-tag-faces '(("imp" . (:foreground "red" :weight bold))))

;; Configure Babel
(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)
   (emacs-lisp . t)
   (shell . t)))

(setq org-confirm-babel-evaluate nil)

;; Refile to any agenda file
(setq org-refile-targets '((org-agenda-files :maxlevel . 2)))

;; Save all Org buffers after refile
(advice-add 'org-refile :after (lambda (&rest r) (org-save-all-org-buffers)))

;; Always refile to top of entry
(setq org-reverse-note-order t)

;;----------------------------------------------------------------------------
;; Package Initialization
;;----------------------------------------------------------------------------

;; Projectile
(projectile-mode +1)

(defun my-projectile-mode-line ()
  "Report project name and type in the modeline."
  (let ((project-name (projectile-project-name))
        (project-type (projectile-project-type)))
    (format " P[%s]" (or project-name "-"))))

(setq projectile-mode-line-function 'my-projectile-mode-line)

;; Magit
(add-to-list 'magit-repository-directories '("~/Workspace/" . 2))

;; Elpy
(elpy-enable)

;; Company
(add-hook 'after-init-hook 'global-company-mode)

;; flymake-shellcheck
(require 'flymake-shellcheck)
(add-hook 'sh-mode-hook 'flymake-shellcheck-load)

;; secret values
(load "~/Dropbox/emacs/secrets.el" t)

;; YAML mode
(add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))

;; Restclient mode
(require 'restclient)
(add-to-list 'auto-mode-alist '("\\.http\\'" . restclient-mode))

;; Avy
(setq avy-all-windows nil)
(setq avy-background t)
(setq avy-keys '(?a ?s ?d ?f ?j ?k ?l ?\;))

;;----------------------------------------------------------------------------
;; Custom Functions
;;----------------------------------------------------------------------------

(defun comment-really-dwim ()
  "Toggle comment on line (or region if active)."
  (interactive)
  (if (use-region-p)
      (comment-or-uncomment-region (region-beginning) (region-end))
    (comment-or-uncomment-region (line-beginning-position) (line-end-position))))

(defun move-line-up ()
  "Move current line up."
  (interactive)
  (when (> (line-number-at-pos) 1)
    (transpose-lines 1)
    (previous-line)
    (previous-line)))

(defun move-line-down ()
  "Move current line down."
  (interactive)
  (when (< (line-number-at-pos) (count-lines (point-min) (point-max)))
    (next-line)
    (transpose-lines 1)
    (previous-line)))

(defun swap-window-pair-buffers ()
  "When two windows are open, swap their buffers."
  (interactive)
  (if (= (count-windows) 2)
      (let* ((w1 (elt (window-list) 0))
	     (w2 (elt (window-list) 1))
	     (b1 (window-buffer w1))
	     (b2 (window-buffer w2)))
	(set-window-buffer w1 b2)
	(set-window-buffer w2 b1))
    (error "This function only works with exactly two windows")))

(defun find-file-general-maybe-other-window (&optional arg)
  "If in a projectile project, use projectile-find file. Otherwise use
ido-find-file. When passed a prefix argument ARG, do it on the other
window."
  (interactive "P")
  (if (null arg)
      (if (projectile-project-p)
	  (projectile-find-file)
	(ido-find-file))
    (save-selected-window
      (if (projectile-project-p)
	  (projectile-find-file-other-window)
	(ido-find-file-other-window)))))

(defun switch-buffer-maybe-other-window (&optional arg)
  "Switch buffer using IDO. When passed a prefix argument ARG, do it
on the other window."
  (interactive "P")
  (if (null arg)
      (ido-switch-buffer)
    (save-selected-window
      (ido-switch-buffer-other-window))))

(defun kill-current-buffer-maybe-other-window (&optional arg)
  "Kill current buffer. When passed a prefix argument ARG, do it on
the other window."
  (interactive "P")
  (if (null arg)
      (kill-current-buffer)
    (when (> (count-windows) 1)
      (save-selected-window
	(other-window 1)
	(kill-current-buffer)))))

(defun close-response-and-request ()
  "Close last HTTP response buffer and send a new request."
  (interactive)
  (while (get-buffer "*HTTP Response*")
    (kill-buffer "*HTTP Response*"))
  (when (= (count-windows) 1)
    (split-window-right))
  (restclient-http-send-current-stay-in-window))

(defun toggle-window-dedicated ()
  "Toggles the selected window's dedicated flag."
  (interactive)
  (let ((win (get-buffer-window)))
    (set-window-dedicated-p win (not (window-dedicated-p win)))
    (message "Window dedicated value is now: %s." (window-dedicated-p win))))

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

(defun shell-with-name ()
  "Create a shell with a specific name."
  (interactive)
  (let ((name (read-string "Shell name: ")))
    (shell (concat "*shell"
		   (if (string= name "") "" (concat " " name))
		   "*"))))

(defun edit-init ()
  "Edit init.el in a buffer."
  (interactive)
  (find-file "~/.emacs.d/init.el"))

(defun duplicate-line ()
  "Duplicate a line, and move point to it (maintain current column)."
  (interactive)
  (kill-ring-save (line-beginning-position) (line-end-position))
  (save-excursion
    (move-end-of-line 1)
    (newline)
    (yank))
  (next-line))

(defun parse-timestamp ()
  "Read date and time from UNIX timestamp in region."
  (interactive)
  (let* ((selection (buffer-substring-no-properties (mark) (point)))
	 (timestamp (string-to-number selection)))
    (if (= timestamp 0)
	(error "Selected value is not an integer value")
      (message (format-time-string "%B %e, %Y - %T (UTC)" timestamp t)))))

(defun create-scratch-buffer ()
  "Create a new scratch buffer in Fundamental mode."
  (interactive)
  (let* ((name (read-string "Scratch buffer name: "))
	 (fullname (concat "*scratch"
			   (if (string= name "") "" (concat " " name))
			   "*")))
    (switch-to-buffer (get-buffer-create fullname))
    (fundamental-mode)))

(defun dired-org-agenda ()
  "Open org-directory with dired."
  (interactive)
  (dired org-directory "-l")
  (dired-hide-details-mode))

(defun clear-all-highlights ()
  "Clears all highlighted items using hi-lock-mode."
  (interactive)
  (unhighlight-regexp t))

(defun print-buffer-file-name ()
  "Print the current buffer's file path."
  (interactive)
  (let ((name (buffer-file-name)))
    (if name
	(message name)
      (error "Buffer is not visiting any file"))))

(defun thing-to-register-dwim (reg)
  "If called with negative prefix argument, prompt for register and
clear its contents. If called with prefix argument (4), prompt for a
register and save window configuration into it. If called with prefix
argument (16), prompt for a register and save frameset configuration
into it. If last executed action was defining a macro, prompt for a
register and save it there. Otherwise, if region is active, copy it to
a register. Otherwise save point position and current buffer to a
register."
  (interactive (list (register-read-with-preview
		      (if (equal current-prefix-arg '-)
			  "Delete register: "
			"Register: "))))
  (cond ((null current-prefix-arg)
	 (cond ((eq last-command 'kmacro-end-or-call-macro)
		(kmacro-to-register reg))
	       ((use-region-p)
		(copy-to-register reg (region-beginning) (region-end)))
	       (t
		(point-to-register reg))))
	((equal current-prefix-arg '-)
	 (setq register-alist (assq-delete-all reg register-alist)))
	((equal current-prefix-arg '(4))
	 (window-configuration-to-register reg))
	((equal current-prefix-arg '(16))
	 (frameset-to-register reg))))

(defun use-register-dwim (reg)
  "Prompt for a register name if called interactively, otherwise use
REG. If the selected register contains text, insert its contents into
the current buffer. If the register contains a point position (or file
query), jump to it. If the register contains a keyboard macro, execute
it. If the register contains a window or frameset configuration, apply
it."
  (interactive (list (register-read-with-preview "Register: ")))
  (let ((contents (get-register reg)))
    (if (stringp contents)
	(insert-register reg)
      (progn
	(when (markerp contents)
	  (let ((w (get-buffer-window (marker-buffer contents) t)))
	    (when w
	      (progn
		(select-frame-set-input-focus (window-frame w))
		(select-window w)))))
	(jump-to-register reg)))))

(defun rename-file-buffer ()
  "Rename the current buffer's file, and the buffer itself to match
the new file name."
  (interactive)
  (let ((current-file-name (buffer-file-name)))
    (if (and current-file-name (not (buffer-modified-p)))
	(let ((new-file-name (read-file-name "New file name:" nil current-file-name 'confirm)))
	  (if (and (not (file-exists-p new-file-name))
		   (not (get-file-buffer new-file-name)))
	      (progn
		(rename-file current-file-name new-file-name)
		(set-visited-file-name new-file-name)
		(set-buffer-modified-p nil))
	    (error "File already exists!")))
      (error "Current buffer is not visiting any file or has unsaved changes"))))

(defun import-icalendar-url (url dest)
  "Download an iCalendar file from URL (asynchronously) and convert it
to a Org mode file, using ical2orgpy. The created file will be placed
in file DEST, inside the current org-directory."
  (interactive "sEnter URL: \nsEnter filename: ")
  (unless (executable-find "ical2orgpy")
    (error "Could not find ical2orgpy executable"))
  (let ((ical-file (make-temp-file "emacs-ical"))
	(org-file (expand-file-name (concat org-directory dest))))
    (with-temp-file ical-file
      (url-insert-file-contents url))
    (if (= 0 (call-process "ical2orgpy" nil nil nil ical-file org-file))
	(message "iCal exported to: %s" org-file)
      (error "ical2orgpy process error"))
    (delete-file ical-file)))

(defun import-google-calendar ()
  "Import calendar from Google Calendar."
  (interactive)
  (import-icalendar-url gcal-url "gcal.org"))

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
  (message "Buffer copied to kill ring."))

(defun json-pretty-print-dwim ()
  "Prettify JSON in region if it is active, otherwise on whole buffer."
  (interactive)
  (if (use-region-p)
      (json-pretty-print (region-beginning) (region-end))
    (json-pretty-print-buffer)))

(defun goto-last-edit ()
  "Go to the last edit made in the current buffer."
  (interactive)
  (unless (or (consp buffer-undo-list)
	      (not buffer-undo-list))
    (error "Can't go to last edit: invalid undo list"))
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

(defun dired-default-directory ()
  "Open dired on the directory contained in `default-directory'."
  (interactive)
  (dired default-directory))

;;----------------------------------------------------------------------------
;; Macros
;;----------------------------------------------------------------------------

(defmacro bind-key-insert-char (key char)
  "Insert a specific character by using a specific key sequence."
  `(global-set-key (kbd ,key)
		   (lambda () (interactive) (insert ,char))))

;;----------------------------------------------------------------------------
;; Keybindings
;;----------------------------------------------------------------------------

(global-set-key (kbd "C-x g") 'magit-status)
(global-set-key (kbd "C-x C-d") 'dired-default-directory)

(global-set-key (kbd "C-o") 'flymake-goto-next-error)
(global-set-key (kbd "C-s") 'isearch-forward-regexp)
(global-set-key (kbd "C-r") 'isearch-backward-regexp)
(global-set-key (kbd "C-j") 'avy-goto-char-timer)
(global-set-key (kbd "C-;") 'comment-really-dwim)
(global-set-key (kbd "C-<") 'scroll-right)
(global-set-key (kbd "C->") 'scroll-left)
(global-set-key (kbd "C-,") 'query-replace-regexp)
(global-set-key (kbd "C-=") 'er/expand-region)
(global-set-key (kbd "C-M-=") 'wrap-region)
(global-set-key (kbd "C-<backspace>") 'backward-delete-word)

(global-set-key (kbd "M-l") 'switch-buffer-maybe-other-window)
(global-set-key (kbd "M-o") 'other-window)
(global-set-key (kbd "M-<up>") 'move-line-up)
(global-set-key (kbd "M-<down>") 'move-line-down)
(global-set-key (kbd "M-n") 'forward-paragraph)
(global-set-key (kbd "M-p") 'backward-paragraph)
(global-set-key (kbd "M-i") 'imenu)
(global-set-key (kbd "M-s h c") 'clear-all-highlights)
(global-set-key (kbd "M-<backspace>") 'goto-last-edit)

(global-set-key (kbd "C-c w s") 'swap-window-pair-buffers)
(global-set-key (kbd "C-c w f") 'fit-window-to-buffer)
(global-set-key (kbd "C-c w w") 'balance-windows)
(global-set-key (kbd "C-c d") 'duplicate-line)
(global-set-key (kbd "C-c n") 'display-line-numbers-mode)
(global-set-key (kbd "C-c f") 'flymake-mode)
(global-set-key (kbd "C-c s SPC") 'spotify-playpause)
(global-set-key (kbd "C-c s s") 'spotify-next)
(global-set-key (kbd "C-c s p") 'spotify-previous)
(global-set-key (kbd "C-c s c") 'spotify-current)
(global-set-key (kbd "C-c c") 'find-file-general-maybe-other-window)
(global-set-key (kbd "C-c k") 'kill-current-buffer-maybe-other-window)
(global-set-key (kbd "C-c j") 'json-pretty-print-dwim)
(global-set-key (kbd "C-c i") 'indent-region)
(global-set-key (kbd "C-c h") 'shell-with-name)
(global-set-key (kbd "C-c e e") 'eval-buffer)
(global-set-key (kbd "C-c e i") 'edit-init)
(global-set-key (kbd "C-c e r") 'rename-file-buffer)
(global-set-key (kbd "C-c e d") 'debbugs-gnu)
(global-set-key (kbd "C-c e p") 'print-buffer-file-name)
(global-set-key (kbd "C-c t") 'parse-timestamp)
(global-set-key (kbd "C-c b") 'create-scratch-buffer)
(global-set-key (kbd "C-c <tab>") 'ibuffer)
(global-set-key (kbd "C-c m") 'kill-ring-save-whole-buffer)
(global-set-key (kbd "C-c r j") 'use-register-dwim)
(global-set-key (kbd "C-c r r") 'thing-to-register-dwim)
(global-set-key (kbd "C-c z") 'apropos)

(global-set-key (kbd "C-c o c") 'org-capture)
(global-set-key (kbd "C-c o a") 'org-agenda)
(global-set-key (kbd "C-c o d") 'dired-org-agenda)
(global-set-key (kbd "C-c o s") 'org-sort)
(global-set-key (kbd "C-c o r") 'org-archive-to-archive-sibling)
(global-set-key (kbd "C-c o t") 'org-force-cycle-archived)
(global-set-key (kbd "C-c o g") 'import-google-calendar)

(global-set-key (kbd "ESC ESC ESC") 'keyboard-quit)

(global-set-key [remap dabbrev-expand] 'hippie-expand)

(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
(define-key restclient-mode-map (kbd "C-c C-v") 'close-response-and-request)
(define-key shell-mode-map (kbd "C-r") 'comint-history-isearch-backward-regexp)
(define-key shell-mode-map (kbd "C-l") 'goto-end-clear-screen)
(define-key shell-mode-map (kbd "C-M-l") 'comint-clear-buffer)

(define-key org-mode-map (kbd "M-n") 'outline-next-visible-heading)
(define-key org-mode-map (kbd "M-p") 'outline-previous-visible-heading)

;; Free keys:
;; C-c SPC
;; C-.
;; M-j
;; M-'
;; M-[
;; M-]

;;----------------------------------------------------------------------------
;; Keys for quick Spanish/German letters insertion
;;----------------------------------------------------------------------------

;; I prefer using "C-c [ a" instead of "C-x 8 ' a" to insert "á" (for example)
;; It's shorter and there's less finger movement involved

(bind-key-insert-char "C-c [ a" "á")
(bind-key-insert-char "C-c [ e" "é")
(bind-key-insert-char "C-c [ i" "í")
(bind-key-insert-char "C-c [ o" "ó")
(bind-key-insert-char "C-c [ u" "ú")
(bind-key-insert-char "C-c [ n" "ñ")
(bind-key-insert-char "C-c [ A" "Á")
(bind-key-insert-char "C-c [ E" "É")
(bind-key-insert-char "C-c [ I" "Í")
(bind-key-insert-char "C-c [ O" "Ó")
(bind-key-insert-char "C-c [ U" "Ú")
(bind-key-insert-char "C-c [ N" "Ñ")
(bind-key-insert-char "C-c [ v" "ü")
(bind-key-insert-char "C-c [ V" "Ü")

(bind-key-insert-char "C-c [ [ a" "ä")
(bind-key-insert-char "C-c [ [ o" "ö")
(bind-key-insert-char "C-c [ [ u" "ü")
(bind-key-insert-char "C-c [ [ s" "ß")
(bind-key-insert-char "C-c [ [ A" "Ä")
(bind-key-insert-char "C-c [ [ O" "Ö")
(bind-key-insert-char "C-c [ [ U" "Ü")

;;----------------------------------------------------------------------------
;; Remove default keybindings
;;----------------------------------------------------------------------------

;; Disable some default keys that get hit by accident

(global-unset-key (kbd "C-x f"))

(define-key elpy-mode-map (kbd "<C-return>") nil)
(define-key elpy-mode-map (kbd "C-c C-c") nil)
(define-key org-mode-map (kbd "C-c [") nil)
(define-key org-mode-map (kbd "C-'") nil)
(define-key shell-mode-map (kbd "C-c C-l") nil)
(define-key python-mode-map (kbd "C-c C-c") nil)

;;----------------------------------------------------------------------------
;; Cleanup
;;----------------------------------------------------------------------------

;; Restore GC threshold
(setq gc-cons-threshold gc-default-threshold)
