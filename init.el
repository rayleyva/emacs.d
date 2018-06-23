;; Requires: Emacs 26+

;;----------------------------------------------------------------------------
;; Emacs General Config
;;----------------------------------------------------------------------------

;; Set GC threshold at 20 Mb
(defconst gc-threshold 20000000)
(setq gc-cons-threshold gc-threshold)

(require 'package)

(setq package-archives
      '(("gnu" . "http://elpa.gnu.org/packages/")
	("marmalade" . "http://marmalade-repo.org/packages/")))

(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)

(package-initialize)

;; Customize
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

;; Show line numbers using new mode (26+)
(global-display-line-numbers-mode 1)

;; Disable tool bar and scroll bar
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(scroll-bar-mode -1)

;; Sort help by relevance
(setq apropos-sort-by-scores t)

;; Disable welcome screen
(setq inhibit-startup-screen t)

;; Show column number
(column-number-mode t)

;; IDO
(ido-mode 1)
(setq ido-everywhere t)
(setq ido-enable-flex-matching t)
(setq ido-separator "\n")
(setq ido-ignore-buffers '("^ " "*Completions*" "*Shell Command Output*" "*Messages*" "*Flymake log*" "*Compile-Log*" "*Help*"))

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
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

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

;; Disable truncate-lines when editing Markdown files
(add-hook 'markdown-mode-hook 'visual-line-mode)

;;----------------------------------------------------------------------------
;; Package Initialization
;;----------------------------------------------------------------------------

;; Projectile
(projectile-global-mode)
(setq-default projectile-mode-line
	      '(:eval (format " Proj[%s]" (projectile-project-name)))
	      )

;; Elpy
(elpy-enable)

;; Company
(add-hook 'after-init-hook 'global-company-mode)

;; Diff-hl on margins
(require 'diff-hl)
(diff-hl-margin-mode)
(add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)

;; Spotify controls
(load "~/.emacs.d/spotify.el")

;; YAML mode
(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))

;;----------------------------------------------------------------------------
;; Custom Functions
;;----------------------------------------------------------------------------

(defun toggle-comment-smart ()
  "Toggle comment on line or region if selected."
  (interactive)
  (if (use-region-p)
      (comment-or-uncomment-region (region-beginning) (region-end))
    (comment-or-uncomment-region (line-beginning-position) (line-end-position))))

(defun neotree-project-dir ()
  "Open NeoTree using the Projectile project root."
  (interactive)
  (let ((project-dir (projectile-project-p))
        (file-name (buffer-file-name)))
    (neotree-toggle)
    (if project-dir
        (if (neo-global--window-exists-p)
            (progn
              (neotree-dir project-dir)
              (neotree-find file-name)))
      (message "Could not find Projectile project root."))))

(defun move-line-up ()
  "Move current line up."
  (interactive)
  (if (> (line-number-at-pos) 1)
      (progn
	(transpose-lines 1)
	(previous-line)
	(previous-line))))

(defun move-line-down ()
  "Move current line down."
  (interactive)
  (if (< (line-number-at-pos) (count-lines (point-min) (point-max)))
      (progn
	(next-line)
	(transpose-lines 1)
	(previous-line))))

(defun find-file-general ()
  (interactive)
  (if (projectile-project-p)
      (projectile-find-file)
    (ido-find-file)))

(defun close-respose-and-request ()
  (interactive)
  (progn
    (when (get-buffer "*HTTP Response*")
      (kill-buffer "*HTTP Response*"))
    (restclient-http-send-current-stay-in-window)))

(defun yank-pop-verbose ()
  "Call yank-pop and show kill ring pointer index value."
  (interactive)
  (progn
    (call-interactively #'yank-pop)
    (let ((ring-len (length kill-ring))
	  (pos
	  (+
	   (-
	    (length kill-ring)
	    (length kill-ring-yank-pointer))
	   1)))
      (message "Yanked element %d of %d." pos ring-len))))

;;----------------------------------------------------------------------------
;; Keybindings
;;----------------------------------------------------------------------------

(global-set-key (kbd "C-j") 'avy-goto-word-or-subword-1)
(global-set-key (kbd "C-x g") 'magit-status)
(global-set-key (kbd "C-x C-d") 'ido-dired)
(global-set-key (kbd "C-z") 'undo)
(global-set-key (kbd "C-;") 'toggle-comment-smart)
(global-set-key (kbd "C-<") 'scroll-right)
(global-set-key (kbd "C->") 'scroll-left)
(global-set-key (kbd "C-<tab>") 'ido-switch-buffer)
(global-set-key (kbd "C-,") 'query-replace-regexp)
(global-set-key (kbd "M-y") 'yank-pop-verbose)
(global-set-key (kbd "M-o") 'other-window)
(global-set-key (kbd "M-<up>") 'move-line-up)
(global-set-key (kbd "M-<down>") 'move-line-down)
(global-set-key (kbd "M-n") 'forward-paragraph)
(global-set-key (kbd "M-p") 'backward-paragraph)
(global-set-key [f8] 'neotree-project-dir)

(global-set-key (kbd "C-c o") 'occur)
(global-set-key (kbd "C-c l") 'comint-clear-buffer)
(global-set-key (kbd "C-c n") 'display-line-numbers-mode)
(global-set-key (kbd "C-c f") 'flymake-mode)
(global-set-key (kbd "C-c g") 'diff-hl-mode)
(global-set-key (kbd "C-c s SPC") 'spotify-play-pause)
(global-set-key (kbd "C-c s s") 'spotify-next)
(global-set-key (kbd "C-c s p") 'spotify-previous)
(global-set-key (kbd "C-c s m") 'spotify-now-playing)
(global-set-key (kbd "C-c c") 'find-file-general)
(add-hook 'restclient-mode-hook
	  (lambda ()
	    (local-set-key (kbd "C-c C-v") 'close-respose-and-request)))

(global-unset-key (kbd "C-x f"))
