(require 'package)
(setq package-enable-at-startup nil)

(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))

(defun ensure-package-installed (&rest packages)
  "Assure every package is installed, ask for installation if it’s not.

Return a list of installed packages or nil for every skipped package."
  (mapcar
   (lambda (package)
     (if (package-installed-p package)
         nil
       (if (y-or-n-p (format "Package %s is missing. Install it? " package))
           (package-install package)
         package)))
   packages))

;; Make sure to have downloaded archive description.
(or (file-exists-p package-user-dir)
    (package-refresh-contents))

;; Activate installed packages
(package-initialize)

(ensure-package-installed 'iedit
                          'magit
                          'evil
                          'evil-leader
                          'evil-search-highlight-persist
                          'helm
                          'elixir-mode
                          'dtrt-indent
                          'relative-line-numbers
                          'autopair
                          'neotree
                          'projectile
                          'helm-projectile
                          'jsx-mode
                          'coffee-mode
                          'multiple-cursors
                          'enh-ruby-mode
                          'markdown-mode
                          'auto-complete
                          'yasnippet
                          'helm-ag
                          'saveplace
                          'ag
                          'fzf
                          'ctags
                          'evil-surround
                          'monokai-theme
                          'powerline-evil)

(setq backup-directory-alist `(("." . "~/.saves")))
(setq backup-by-copying t)
(setq delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t)

;;;;;;;;;;;;;
; Evil Mode ;
;;;;;;;;;;;;;
(require 'evil-leader)
(global-evil-leader-mode)

(setq evil-leader/in-all-states 1)
(setq evil-leader/no-prefix-mode-rx '("magit-.*-mode" "gnus-.*-mode"))
(evil-leader/set-leader ",")

;  "f"  'helm-projectile-find-file
(evil-leader/set-key
  "hf" 'describe-function
  " "  'evil-search-highlight-persist-remove-all
  "f"  'fzf
  "df" 'helm-projectile-find-dir
  "a"  'helm-projectile-ag
  "bt" 'build-ctags
  "w"  'save-buffer)

(require 'evil)
(evil-mode t)

;;; esc quits
(defun minibuffer-keyboard-quit ()
  "Abort recursive edit.
In Delete Selection mode, if the mark is active, just deactivate it;
then it takes a second \\[keyboard-quit] to abort the minibuffer."
  (interactive)
  (if (and delete-selection-mode transient-mark-mode mark-active)
      (setq deactivate-mark  t)
    (when (get-buffer "*Completions*") (delete-windows-on "*Completions*"))
    (abort-recursive-edit)))
(define-key evil-normal-state-map [escape] 'keyboard-quit)
(define-key evil-visual-state-map [escape] 'keyboard-quit)
(define-key minibuffer-local-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-ns-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-completion-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-must-match-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-isearch-map [escape] 'minibuffer-keyboard-quit)
(define-key evil-normal-state-map (kbd "C-h") 'evil-window-left)
(define-key evil-normal-state-map (kbd "C-j") 'evil-window-down)
(define-key evil-normal-state-map (kbd "C-k") 'evil-window-up)
(define-key evil-normal-state-map (kbd "C-l") 'evil-window-right)

(setq evil-emacs-state-cursor '("red" box))
(setq evil-normal-state-cursor '("green" box))
(setq evil-visual-state-cursor '("orange" box))
(setq evil-insert-state-cursor '("red" bar))
(setq evil-replace-state-cursor '("red" bar))
(setq evil-operator-state-cursor '("red" hollow))

                                        ; Link up :noh to evil search highlighting persist
(defun remove-highlighting () (evil-search-highlight-persist-remove-all))
(advice-add 'evil-ex-nohighlight :after #'remove-highlighting)

(setq-default
 interprogram-cut-function   nil
 interprogram-paste-function nil
 x-select-enable-clipboard   nil)

(defun copy-from-osx ()
  (interactive)
  (shell-command-to-string "pbpaste"))

(defun paste-to-osx (text &optional push)
  (interactive)
  (let ((process-connection-type nil))
    (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
      (process-send-string proc text)
      (process-send-eof proc))))

(setq interprogram-cut-function 'paste-to-osx)
(setq interprogram-paste-function 'copy-from-osx)

;;;;;;;;;;;;;;;;;;
; General Config ;
;;;;;;;;;;;;;;;;;;
(setq inhibit-splace-screen t
      inhibit-startup-screen t
      inhibit-startup-echo-area-message t)

(menu-bar-mode -1)
(tool-bar-mode -1)
(when (boundp 'sroll-bar-modes)
  (scroll-bar-mode -1))
(show-paren-mode 1)
(setq visual-line-fringe-indicators '(left-curly-arrow right-curly-arrow))
(setq-default left-fringe-width nil)
(setq-default indent-tabs-mode nil)
(eval-after-load "vc" '(setq vc-handled-backends nil))
(setq vc-follow-symlinks t)
(setq large-file-warning-threshold nil)
(setq split-width-threshold nil)
(setq custom-safe-themes t)
(put 'narrow-to-region 'disabled nil)

(define-key global-map (kbd "RET") 'newline-and-indent)

; Remember cursor position
(require 'saveplace)
(setq-default save-place t)

(require 'dtrt-indent)
(dtrt-indent-mode 1)

(require 'autopair)
(autopair-global-mode)

(require 'jsx-mode)
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . jsx-mode))

(require 'coffee-mode)

(add-to-list 'auto-mode-alist '("\\.coffee\\'" . coffee-mode))

(require 'enh-ruby-mode)

(require 'multiple-cursors)

(require 'dirtree)

(require 'yasnippet)
(yas-global-mode 1)

(require 'neotree)
(setq neo-smart-open t)
(global-set-key [f8] 'neotree-toggle)
(setq projectile-switch-project-action 'neotree-projectile-action)
(add-hook 'neotree-mode-hook
          (lambda ()
            (define-key evil-normal-state-local-map (kbd "TAB") 'neotree-enter)
            (define-key evil-normal-state-local-map (kbd "SPC") 'neotree-enter)
            (define-key evil-normal-state-local-map (kbd "q") 'neotree-hide)
            (define-key evil-normal-state-local-map (kbd "RET") 'neotree-enter)))

(setq company-idle-delay 1)

;;;;;;;;;;;;;;;;;
;  Autocomplete ;
;;;;;;;;;;;;;;;;;
(ac-config-default)


;;;;;;;;;
; CTags ;
;;;;;;;;;
(defun build-ctags ()
  (interactive)
  (message "building project tags")
  (async-shell-command (concat "ctags -e -R --extra=+fq --exclude=db --exclude=test --exclude=.git TAGS ."))
  (visit-project-tags)
  (message "tags built successfully"))

(defun visit-project-tags ()
  (interactive)
  (visit-tags-table "TAGS")
  (message (concat "Loaded " "TAGS")))

;;;;;;;;
; Helm ;
;;;;;;;;
(require 'helm-config)
(require 'helm-projectile)
(require 'helm-ag)
(helm-mode 1)
(helm-projectile-on)
(define-key evil-normal-state-map " " 'helm-mini)

;;;;;;;;;;;;;;;;;;;;;;;
; Search Highlighting ;
;;;;;;;;;;;;;;;;;;;;;;;
(require 'evil-search-highlight-persist)
(global-evil-search-highlight-persist t)
(evil-leader/set-key "SPC" 'evil-search-highlight-persist-remove-all)

;;;;;;;;;;;;;
; Powerline ;
;;;;;;;;;;;;;
(require 'powerline)
(powerline-evil-vim-color-theme)
(display-time-mode t)

;;;;;;;;;;;;;;;;;;;;;;;;;
; Relative line numbers ;
;;;;;;;;;;;;;;;;;;;;;;;;;
(add-hook 'prog-mode-hook 'relative-line-numbers-mode t)
(add-hook 'prog-mode-hook 'line-number-mode t)
(add-hook 'prog-mode-hook 'column-number-mode t)

;;;;;;;;;;;;;;;;;
; Pretty colors ;
;;;;;;;;;;;;;;;;;
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
(load-theme 'monokai t)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("c567c85efdb584afa78a1e45a6ca475f5b55f642dfcd6277050043a568d1ac6f" default))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
