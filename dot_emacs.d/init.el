(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)

(setq gc-cons-threshold 100000000)
(setq inhibit-startup-message t)

(defalias 'yes-or-no-p 'y-or-n-p)

;; Automatically install packages and dependencies ---------------------------------------

(defconst packages-to-install
  '(anzu
    company
    duplicate-thing
    ggtags
    helm
    helm-gtags
    helm-projectile
    helm-swoop
    function-args
    clean-aindent-mode
    comment-dwim-2
    dtrt-indent
    ws-butler
    iedit
    yasnippet
    smartparens
    projectile
    volatile-highlights
    undo-tree
    zygospore))

(defun install-packages ()
  "Install all required packages."
  (interactive)
  (unless package-archive-contents
    (package-refresh-contents))
  (dolist (package packages-to-install)
    (unless (package-installed-p package)
      (package-install package))))

(install-packages)

;; Helm configuration ----------------- --------------------------------------------------

;; this variables must be set before load helm-gtags
;; you can change to any prefix key of your choice
(setq helm-gtags-prefix-key "\C-cg")

(add-to-list 'load-path "~/.emacs.d/custom")

(require 'setup-helm)
(require 'setup-helm-gtags)
;; (require 'setup-ggtags) ; using helm instead of ggtags
(require 'setup-cedet)
(require 'setup-editing)

(windmove-default-keybindings)

;; function-args
(require 'function-args)
(fa-config-default)
(define-key c-mode-map  [(tab)] 'company-complete)
(define-key c++-mode-map  [(tab)] 'company-complete)

;; company
(require 'company)
(add-hook 'after-init-hook 'global-company-mode)
(delete 'company-semantic company-backends)
(define-key c-mode-map  [(tab)] 'company-complete)
(define-key c++-mode-map  [(tab)] 'company-complete)

;; company-c-headers
(add-to-list 'company-backends 'company-c-headers)

;; hs-minor-mode for folding source code
(add-hook 'c-mode-common-hook 'hs-minor-mode)

;; Available C style:
;; “gnu”: The default style for GNU projects
;; “k&r”: What Kernighan and Ritchie, the authors of C used in their book
;; “bsd”: What BSD developers use, aka “Allman style” after Eric Allman.
;; “whitesmith”: Popularized by the examples that came with Whitesmiths C, an early commercial C compiler.
;; “stroustrup”: What Stroustrup, the author of C++ used in his book
;; “ellemtel”: Popular C++ coding standards as defined by “Programming in C++, Rules and Recommendations,” Erik Nyquist and Mats Henricson, Ellemtel
;; “linux”: What the Linux developers use for kernel development
;; “python”: What Python developers use for extension modules
;; “java”: The default style for java-mode (see below)
;; “user”: When you want to define your own style

(setq
 c-default-style "linux" ;; set style to "linux"
 )

(global-set-key (kbd "RET") 'newline-and-indent)  ; automatically indent when press RET

;; activate whitespace-mode to view all whitespace characters
(global-set-key (kbd "C-c w") 'whitespace-mode)

;; show unncessary whitespace that can mess up your diff
(add-hook 'prog-mode-hook (lambda () (interactive) (setq show-trailing-whitespace 1)))

;; use space to indent by default
;(setq-default indent-tabs-mode nil)

;; set appearance of a tab that is represented by 4 spaces
;(setq-default tab-width 4)

;; Compilation
(global-set-key (kbd "<f5>") (lambda ()
                               (interactive)
                               (setq-local compilation-read-command nil)
                               (call-interactively 'compile)))

;; setup GDB
(setq
 ;; use gdb-many-windows by default
 gdb-many-windows t

 ;; Non-nil means display source file containing the main routine at startup
 gdb-show-main t
 )

;; Package: clean-aindent-mode
(require 'clean-aindent-mode)
(add-hook 'prog-mode-hook 'clean-aindent-mode)

;; Package: dtrt-indent
(require 'dtrt-indent)
(dtrt-indent-mode 1)

;; Package: ws-butler
(require 'ws-butler)
(add-hook 'prog-mode-hook 'ws-butler-mode)
;;(add-hook 'GNUmakefile 'ws-butler-mode)
;(add-hook 'makefile-mode 'indent-tabs-mode)
;(eval-after-load 'makefile-mode (setq indent-tabs-mode t))


;; Package: yasnippet
(require 'yasnippet)
(yas-global-mode 1)

;; Package: smartparens
(require 'smartparens-config)
(setq sp-base-key-bindings 'paredit)
(setq sp-autoskip-closing-pair 'always)
(setq sp-hybrid-kill-entire-symbol nil)
(sp-use-paredit-bindings)

(show-smartparens-global-mode +1)
(smartparens-global-mode 1)

;; Package: projejctile
(require 'projectile)
(projectile-global-mode)
(setq projectile-enable-caching t)

(require 'helm-projectile)
(helm-projectile-on)
(setq projectile-completion-system 'helm)
(setq projectile-indexing-method 'alien)

;; Package zygospore
(global-set-key (kbd "C-x 1") 'zygospore-toggle-delete-other-windows)


(setq magic-mode-alist nil)

;; Display, coloring, fontsize -----------------------------------------------------------

; Font size 10 on my laptop, 12 everywhere else.

(set-face-attribute 'default nil :height 120)
(set-face-attribute 'default nil :height
            (if (and (display-graphic-p)
                 (or (= (x-display-pixel-height) 1050)
                 (= (x-display-pixel-height) 1080)))
            100 80))

(setq rst-level-face-base-light 30) ;RST section header is abysmal otherwise

                                        ; Coloring things assuming that I have 256 colors.
(if (or (string= (getenv "TERM") "xterm-256color")
        (string= system-type "windows-nt"))
    (progn
      (add-to-list 'load-path "~/.emacs.d/color-theme-6.6.0")
      (require 'color-theme)
      (color-theme-initialize)
                                        ;(color-theme-euphoria)
      (set-face-foreground 'font-lock-preprocessor-face "light gray")
      (set-face-foreground 'font-lock-constant-face "light gray")
      (require 'hl-line)
      (global-hl-line-mode t)
      ;(set-face-background hl-line-face "gray10")
      )
                                        ; Color options if I only have 8 colors.
  (progn
  (set-face-foreground 'font-lock-comment-face "red")))



;; General C++ Customizations ------------------------------------------------------------

(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.c\\'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.hh\\'" . c++-mode))
; Jump to corresponding header files. Courtesy of E. Lunderberg
(eval-after-load 'cc-mode
  '(define-key c++-mode-map (kbd "C-c C-f") 'ff-find-related-file))
(setq cc-search-directories '("." "../src" "../include" "src" "include" "/usr/include"
                              "./*/include" "../include/*" "../include/*/detail"
                              "../../src" "../../include"
                              "../../../src" "../libraries/*"
                              "../../../include" "../libraries/*/*"
                              "../../*/include" "../../*/src"
                                                             ))


;; Emacs ide customizations --------------------------------------------------------------

; enable multi-terminal support for emacs
(require 'multi-term)
(setq multi-term-program "/bin/bash")
;(define-key global-map (kbd "C-c t") 'term-line-mode)
(define-key term-mode-map (kbd "C-j") 'term-char-mode)
(define-key term-raw-map (kbd "C-j") 'term-line-mode)
; return to position in buffer when done with multi-term
(setq multi-term-dedicated-select-after-open-p t)
(setq multi-term-dedicated-close-back-to-open-buffer-p t)
; keybind to open multi-term buffer
(define-key global-map (kbd "C-x t") 'multi-term-dedicated-toggle)

;;;;;;;;;;;;;;;;;;;;;
(global-set-key (kbd "C-z") 'self-insert-command)
(global-set-key (kbd "M-n") 'self-insert-command)
;;;;;;;;;;;;;;;;;;;;;


; dired+ reuse the same buffer when clicking through directories
;(toggle-diredp-find-file-reuse-dir 1)
(require 'dired-single)
(defun my-dired-init ()
  "Bunch of stuff to run for dired, either immediately or when it's
        loaded."
  ;; <add other stuff here>
  (define-key dired-mode-map [return] 'dired-single-buffer)
  (define-key dired-mode-map [mouse-1] 'dired-single-buffer-mouse)
  (define-key dired-mode-map "^"
    (function
     (lambda nil (interactive) (dired-single-buffer "..")))))

;; if dired's already loaded, then the keymap will be bound
(if (boundp 'dired-mode-map)
    ;; we're good to go; just add our bindings
    (my-dired-init)
  ;; it's not loaded yet, so add our bindings to the load-hook
  (add-hook 'dired-load-hook 'my-dired-init))


; comment color should be red
(set-face-foreground 'font-lock-comment-face "red")

; dired multiple buffer regex replace - dir - wildcard
; t for toggle - Q for query regex search and replace
(define-key global-map (kbd "C-c s") 'find-name-dired)

; Fix iedit bug in Mac
(define-key global-map (kbd "C-c :") 'iedit-mode)
;(eval-after-load 'F90-mode
;  '(define-key c++-mode-map (kbd "C-c :") 'iedit-mode))


;; multiple-cursors config ---------------------------------------------------------------

(require 'multiple-cursors)
; define keybinds for selecting next and previous marked expression
(define-key global-map (kbd "C-c n") 'mc/mark-next-like-this)
(define-key global-map (kbd "C-c p") 'mc/mark-previous-like-this)
;(define-key global-map (kbd "C-c C-,") 'mc/mark-all-like-this)
;(define-key global-map (kbd "C-.") 'mc/mark-more-like-this-extended)


;; Window settings -----------------------------------------------------------------------


; Removes top menu bar
(menu-bar-mode -1)
; Removes scroll bar
(scroll-bar-mode -1)

; Disable tool bar in GUI
(tool-bar-mode -1)


;; line numbers via linum-mode
(add-to-list 'load-path "~/.emacs.d/lisp/")
;(load-file "~/apps/emacs_apps/linum/linum.el")
(global-linum-mode 0)
(defun linum-face-settings ()
  "Face settings for `linum'."
  (custom-set-faces
   '(linum
     ((((background dark))
       :foreground "cyan")
      (t :foreground "gray")))))
(eval-after-load 'linum
  `(linum-face-settings))
(provide 'linum-face-settings)
(setq linum-format " %d ")
(autoload 'linum-mode "linum" "toggle line numbers on/off" t)
(global-set-key (kbd "C-c C-l") 'linum-mode)



;; all purpose keybinds ------------------------------------------------------------------


(if (display-graphic-p)

(progn
; Move cursor down 5 lines
;(global-set-key (kbd "<down>")    (lambda () (interactive) (next-line 6)))
; Move cursor up 1 lines
;(global-set-key (kbd "<up>")
;    (lambda () (interactive) (next-line -6)))
; Move cursor 1 columns to the right
;(global-set-key (kbd "<right>")
;    (lambda () (interactive) (forward-char 6)))
; Move cursor 1 columns to the left
;(global-set-key (kbd "<left>")
;    (lambda () (interactive) (backward-char 6)))
; Move cursor down 5 lines
;(global-set-key (kbd "M-k")    (lambda () (interactive) (next-line 1)))
; Move cursor up 1 lines
;(global-set-key (kbd "M-i")
;    (lambda () (interactive) (next-line -1)))
; Move cursor 1 columns to the right
;(global-set-key (kbd "M-l")
;    (lambda () (interactive) (forward-char 1)))
; Move cursor 1 columns to the left
;(global-set-key (kbd "M-j")
;    (lambda () (interactive) (backward-char 1)))
)
(progn
; Move cursor down 1 lines
(global-set-key (kbd "C-n")    (lambda () (interactive) (next-line 1)))
; Move cursor up 1 lines
(global-set-key (kbd "C-p")
    (lambda () (interactive) (next-line -1)))
; Move cursor 1 columns to the right
(global-set-key (kbd "C-f")
    (lambda () (interactive) (forward-char 1)))
; Move cursor 1 columns to the left
(global-set-key (kbd "C-b")
    (lambda () (interactive) (backward-char 1)))
))

; Toggle line truncation
(global-set-key (kbd "C-x l")
    (lambda () (interactive) (toggle-truncate-lines)))


;; fortran alignment ---------------------------------------------------------------------


(require 'align)
(add-to-list 'align-open-comment-modes 'f90-mode)
(add-to-list 'align-dq-string-modes    'f90-mode)
(add-to-list 'align-sq-string-modes    'f90-mode)
(add-hook 'f90-mode-hook
          '(lambda ()
             (setq align-mode-rules-list
                   '((f90-bracket-in-declaration
                      (regexp . "\\(\\s-+\\)([^ :]+).*::"))
                     (f90-comma-in-declaration
                      (regexp . "\\(\\s-*\\),\\s-+.*::")
                      (spacing   . 0))
                     (f90-dimension-in-declaration
                      (regexp    . "\\(\\s-*\\),\\s-*dimension.*::")
                      (spacing   . 0)
                      (case-fold . t))
                     (f90-alloc-in-declaration
                      (regexp    . "\\(\\s-*\\),\\s-*allocatable.*::")
                      (spacing   . 0)
                      (case-fold . t))
                     (f90-intent-in-declaration
                      (regexp    . "\\(\\s-*\\),\\s-*intent.*::")
                      (spacing   . 0)
                      (case-fold . t))
                     (f90-parameter-in-declaration
                      (regexp    . "\\(\\s-*\\),\\s-*parameter.*::")
                      (spacing   . 0)
                      (case-fold . t))
                     (f90-save-in-declaration
                      (regexp    . "\\(\\s-*\\),\\s-*save.*::")
                      (spacing   . 0)
                      (case-fold . t))
                     (f90-colon-in-declaration       ; must come last
                      (regexp . "\\(\\s-+\\):: "))))))
(global-set-key "\C-ca" 'align)



;; emacs auto-gen custom-vars ------------------------------------------------------------


;; themeing when in X mode and not when in terminal mode
;(when (display-graphic-p)
(load-theme 'tangotango t)

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(flymake-google-cpplint-command "/usr/local/bin/cpplint")
 '(inhibit-startup-screen t)
 '(truncate-lines nil))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "#111111" :foreground "#eeeeec" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 83 :width normal :foundry "unknown" :family "DejaVu Sans Mono"))))
 '(custom-comment ((((class grayscale color) (background dark)) (:background "red"))))
 '(flymake-errline ((((class color) (background dark)) (:background "white" :foreground "black"))))
 '(font-lock-builtin-face ((t (:foreground "#729fcf"))))
 '(font-lock-comment-face ((t (:foreground "red"))))
 '(font-lock-keyword-face ((t (:foreground "#33cccc" :weight bold))))
 '(font-lock-string-face ((t (:foreground "#111111" :background "lime green" :slant italic))))
 '(linum ((((background dark)) :foreground "cyan") (t :foreground "gray")))
 '(semantic-tag-boundary-face ((((class color) (background dark)) nil)))
 '(semantic-unmatched-syntax-face ((((class color) (background dark)) nil)))
 '(semantic-unmatched-syntax-face ((((class color) (background dark)) nil)))
)


;; enable forward delete with delete key in x11 mode
(normal-erase-is-backspace-mode 1)
;; disable yas-minor mode in terminal environment in x11
(add-hook 'term-mode-hook (lambda()
                (yas-minor-mode -1)
        (yas-global-mode -1)
        ))
;) ;;end theming

(setq term-default-bg-color (face-background 'default))
(setq term-default-fg-color "#eeeeec")




;; terminal mouse input + scroll ---------------------------------------------------------

(unless window-system
  (xterm-mouse-mode 1)
  (global-set-key [mouse-4] '(lambda ()
                               (interactive)
                               (scroll-down 1)))
  (global-set-key [mouse-5] '(lambda ()
                               (interactive)
                               (scroll-up 1))))

;; background process --------------------------------------------------------------------

(define-key global-map (kbd "C-x M-p") '(lambda() (interactive) (async-shell-command (format "cd %s; git add %s; git commit -m 'Incremental Update'; " default-directory (current-buffer)))))

(load-file "~/.emacs.d/devel-notes.el")
(require 'devel-notes)



;; Allows for calculations within emacs --------------------------------------------------

(defun replace-last-sexp () ; Courtesy Eric Lunderberg
  (interactive)
  (let ((value (eval (preceding-sexp))))
    (kill-sexp -1)
    (insert (format "%s" value))))
(global-set-key (kbd "C-c c") 'replace-last-sexp)


;; More IDE options (comments etc) -------------------------------------------------------

(global-set-key (kbd "C-x ;") 'comment-or-uncomment-region) ;Preferred over comment-dwim

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("5d9351cd410bff7119978f8e69e4315fd1339aa7b3af6d398c5ca6fac7fd53c7" default)))
 '(flymake-google-cpplint-command "/usr/local/bin/cpplint")
 '(inhibit-startup-screen t)
 '(truncate-lines nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
; '(default ((t (:inherit nil :stipple nil :background "#111111" :foreground "#eeeeec" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 83 :width normal :foundry "unknown" :family "DejaVu Sans Mono"))))
 '(custom-comment ((((class grayscale color) (background dark)) (:background "red"))))
 '(flymake-errline ((((class color) (background dark)) (:background "white" :foreground "black"))))
 '(font-lock-builtin-face ((t (:foreground "#729fcf"))))
 '(font-lock-comment-face ((t (:foreground "red"))))
 '(font-lock-function-name-face ((t (:foreground "purple"))))
 '(font-lock-keyword-face ((t (:foreground "#33cccc" :weight bold))))
 '(font-lock-string-face ((t (:foreground "#111111" :background "lime green" :slant italic))))
 '(linum ((((background dark)) :foreground "cyan") (t :foreground "gray")))
 '(semantic-tag-boundary-face ((((class color) (background dark)) nil)))
 '(semantic-unmatched-syntax-face ((((class color) (background dark)) nil))))


(load-file "~/.emacs.d/hide-comnt.el")

(add-hook 'c-mode-common-hook
      (lambda()
        (local-set-key (kbd "C-c <right>") 'hs-show-block)
        (local-set-key (kbd "C-c <left>")  'hs-hide-block)
        (local-set-key (kbd "C-c <up>")    'hs-hide-all)
        (local-set-key (kbd "C-c <down>")  'hs-show-all)
        (hs-minor-mode t)))
(add-hook 'cc-mode-common-hook
      (lambda()
        (local-set-key (kbd "C-c <right>") 'hs-show-block)
        (local-set-key (kbd "C-c <left>")  'hs-hide-block)
        (local-set-key (kbd "C-c <up>")    'hs-hide-all)
        (local-set-key (kbd "C-c <down>")  'hs-show-all)
        (hs-minor-mode t)))
(put 'downcase-region 'disabled nil)

; for compiling a makefile project source in emacs
(load-file "~/.emacs.d/makefile.el")
