;; Cosas de Customize
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(delete-selection-mode t)
 '(desktop-restore-eager 4)
 '(grep-find-ignored-directories
   (quote
    ("SCCS" "RCS" "CVS" "MCVS" ".src" ".svn" ".git" ".hg" ".bzr" "_MTN" "_darcs" "{arch}" "env" "venv" "build")))
 '(grep-find-template
   "find <D> <X> -type f <F> -exec grep <C> -C 3 -nH --null -e <R> \\{\\} +")
 '(package-selected-packages
   (quote
    (yaml-mode restclient debbugs diff-hl neotree magit elpy monokai-theme projectile markdown-mode)))
 '(winner-mode t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
