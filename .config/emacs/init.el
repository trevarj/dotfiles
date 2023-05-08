;;
;; Add MELPA package manager
;; https://melpa.org
;;

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

;;
;; Keybindings
;;

(global-set-key (kbd "C-c /") 'comment-line)
(global-set-key (kbd "C-c n") 'next-buffer)
(global-set-key (kbd "C-c p") 'previous-buffer)

;;
;; Options
;;

;; Hide menu bar
(menu-bar-mode -1)
;; Fix vertical split character (terminal)
(set-display-table-slot standard-display-table 'vertical-border ?│)
;; Show built-in tab line to show all buffers
(global-tab-line-mode 1)
;; Show relative line numbers
(global-display-line-numbers-mode 1)
(setq display-line-numbers 'relative)

;; Nord theme automatically added thing
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("46f5e010e0118cc5aaea1749cc6a15be4dfce27c0a195a0dff40684e2381cf87" default))
 '(package-selected-packages '(nord-theme)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
