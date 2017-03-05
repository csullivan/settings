;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;       makefile customizations       ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun parent-directory (dir)
  (unless (equal "/" dir)
    (file-name-directory (directory-file-name dir))))

(defun find-file-in-hierarchy (current-dir pattern)
  (let ((filelist (directory-files current-dir 'absolute pattern))
	(parent (parent-directory (expand-file-name current-dir))))
    (if (> (length filelist) 0)
	(car filelist)
      (when parent
	(find-file-in-hierarchy parent pattern)))))

(setq compilation-scroll-output 'first-error)

(defun determine-compile-program (filename)
  (cond ((string-match "\\(GNUm\\|M\\|m\\)akefile" filename) "make")
	((equal filename "SConstruct") "scons")))

(defun find-makefile-compile-impl (clean threads)
  (let ((file (find-file-in-hierarchy (file-name-directory buffer-file-name)
				      "\\(\\(GNUm\\|M\\|m\\)akefile\\)\\|\\(SConstruct\\)")))
    (when file
      (let* ((directory (file-name-directory file))
	     (filename (file-name-nondirectory file))
	     (program (determine-compile-program filename))
	     (cleanflag (if clean
			    (if (equal program "make") "clean" "-c")
			  "")))
	(compile (format "cd \"%s\" && %s -j%d %s"
			 directory program threads cleanflag))))))

(defun find-makefile-compile (clean)
  (interactive "p")
  (find-makefile-compile-impl (> clean 1) 1))

(defun find-makefile-compile-fast (clean)
  (interactive "p")
  (find-makefile-compile-impl (> clean 1) 8))

(require 'ansi-color)
(defun colorize-compilation-buffer ()
  (toggle-read-only)
  (ansi-color-apply-on-region (point-min) (point-max))
  (toggle-read-only))
(add-hook 'compilation-filter-hook 'colorize-compilation-buffer)

(add-to-list 'auto-mode-alist '("\\.inc\\'" . makefile-gmake-mode))
(eval-after-load 'make-mode
  '(progn
     (define-key makefile-mode-map (kbd "C-c c") 'find-makefile-compile)
     (define-key makefile-mode-map (kbd "C-c C-c") 'find-makefile-compile-fast)))

(add-hook 'c-initialization-hook '(lambda ()
   (define-key c-mode-base-map (kbd "C-c c") 'find-makefile-compile)
   (define-key c-mode-base-map (kbd "C-c C-c") 'find-makefile-compile-fast)))"\""))"")))))\\)\\)\\)")))))\\)"))))
