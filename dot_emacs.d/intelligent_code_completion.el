; -*-Lisp-*-

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;                                                                 ;;;
;;;         --  Intelligent code completion for emacs  --           ;;;
;;;                                                                 ;;;
;;; This is a minimal distribution of the necessary packages needed ;;;
;;; for intelligent code completion and class method parsing in em- ;;;
;;; acs. It utilizes auto-complete, yasnippet, ac-complete-c-heade- ;;;
;;; rs, and irony-mode.                                             ;;;
;;;                                                                 ;;;
;;; Written by Chris Sullivan - NSCL 07/05/2014                     ;;;
;;;                                                                 ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;                                                                 ;;;
;;;                          -- Usage --                            ;;;
;;;                                                                 ;;;
;;; In a C/C++ buffer C-c C-g toggles auto-completion. When activa- ;;;
;;; ted code suggestions are automatically displayed. Globally off  ;;;
;;; by default.                                                     ;;;
;;;                                                                 ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Initialize ELPA package manager   ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;(when
;    (load
;     (expand-file-name "~/.emacs.d/package.el"))
;  (package-initialize))

;; add the MELPA repo
(require 'package)
(add-to-list 'package-archives
  '("melpa" . "http://melpa.milkbox.net/packages/") t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Start auto-complete & configure   ;;;
;;;       Start Yasnippet as well       ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; start auto-complete with emacs
(require 'auto-complete)
; do default config for auto-complete
(require 'auto-complete-config)
(ac-config-default)
; start yasnippet with emacs
(require 'yasnippet)
(yas-global-mode 1)
; a function which initializes auto-complete-c-headers and gets called for c/c++ hooks
(defun my:ac-c-header-init ()
  (require 'auto-complete-c-headers)
  (add-to-list 'ac-sources 'ac-source-c-headers)
  (add-to-list 'achead:include-directories '"/usr/include/c++/4.7")
)
; call above function from c/c++ hooks
(add-hook 'c++-mode-hook 'my:ac-c-header-init)
(add-hook 'c-mode-hook 'my:ac-c-header-init)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Start Irony-Mode   ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; set LD_LIBRARY_PATH - path to libclang.so
(setenv "LD_LIBRARY_PATH" "/usr/lib/")
; load irony-mode
( add-to-list 'load-path (expand-file-name "~/.emacs.d/irony-mode/elisp/"))
(require 'irony)
; also enable ac plugin
(irony-enable 'ac)
; define a function to start irony mode for c/c++ modes
(defun my:irony-enable()
  (when (member major-mode irony-known-modes)
    (irony-mode 1)))
(add-hook 'c++-mode-hook 'my:irony-enable)
(add-hook 'c-mode-hook 'my:irony-enable)
; since ac is already started, this turns ac off by default. 
; it can then be started with the below keybind
(global-auto-complete-mode)
;(eval-after-load 'cc-mode
;  '(define-key c++-mode-map (kbd "C-c C-d")  'auto-complete-mode))
(define-key global-map (kbd "C-c C-g")  'auto-complete-mode)
