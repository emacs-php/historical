;;;             Copyright (C) 1997 Kazunori Nishi
;;;                   kazunori@kazu.nori.org
;;;
;;; php-mode.el --- major mode for editing php (and phtml) code
;;;
;;; @version 1.3, 13 Oct 1997
;;;

;;; 1. Install
;;; 
;;;         1. Put `php-mode.el' and `php-functions-doc' into a directory
;;;            specified by load-path. (ex. "~/emacs")
;;;         2. Set the variable `php-document-file' in this script
;;;            to the above file(php-functions-doc).
;;;         3. Load `php-mode.el', and type "M-x php-mode".
;;;            It is a good idea to put the following line to "~/.emacs".
;;;            (autoload 'php-mode "/your/path/emacs/php-mode" nil t)
;;; 
;;; 2. Usage
;;; 
;;;         o "\M-\C-i" complete the currect word as a function of php,
;;; 
;;;             [example1] You can complete `Abs' by `ab' + "\M-\C-i"
;;;                 ab "\M-\C-i"
;;;                    => Abs
;;; 
;;;             [example2] You can get the usage by the more "\M-\C-i"
;;;                 Abs "\M-\C-i"
;;;                    =>
;;;              ----------------------------------------------------------
;;;                 Abs(arg)
;;;                     Abs returns the absolute value of arg.
;;;              ----------------------------------------------------------
;;;
;;;          o "\C-c\C-f" asks a function-name, and gives the usage.
;;;             The key-map is as following, in these usage window.
;;;              ----------------------------------------------------------
;;;                 SPACE	scroll-down
;;;                 BS		scroll-up
;;;                 w		ask another function
;;;                 <		goto top of the usage
;;;                 >		goto buttom of the usage
;;;                 1		make the usage window full-window
;;;                 q		quit the usage mode
;;;              ----------------------------------------------------------
;;;
;;; 3. Trouble and Suggestion
;;;              Mail to `kazunori@kazu.nori.org'!!
;;;

(autoload 'c++-mode "cplus-md" nil t)
(provide 'php-mode)

;;; path to the functions document
;;; it won't work when invalid filename
(setq php-document-file "~/php-functions-doc")

;;; the indent level in emacs-19.28.1 
(setq c-indent-level 4)

;;; show the function usage by completion after full-completion
(setq php-auto-describe t)

;;; path to the `php.cgi'
;;; under-constuction
(setq php-prog-cgi "/usr/local/bin/php.cgi")

;;; option to pass to the `php.cgi'
;;; under-constuction
(setq php-prog-cgi-arg "-q")

(defvar php-help-buffer-name " *Php function Help* ")

(defvar php-mode-map ()
  "Keymap used in php-mode.")


(setq php-mode-hook
      '(lambda ()
	 (define-key php-mode-map "\M-\C-i" 'php-complete-symbol)
	 (define-key php-mode-map "\C-c\C-f" 'php-describe-function)
;	 (define-key php-mode-map "\C-i" 'php-indent-command)
	 (if (not (boundp 'php-alist))
	     (setq php-alist (php-get-alist)))))

;;; This is php-mode. The fact is a wrapper to "c++-mode".
(defun php-mode ()
  "Major mode for editing php code. \\{php-mode-map}"
  (interactive)
  (let ((current-c++-mode-hook (and (boundp 'c++-mode-hook) c++-mode-hook)))
    (setq c++-mode-hook nil)
    (c++-mode)
    (setq php-mode-map c++-mode-map)
    (use-local-map php-mode-map)

    (setq major-mode 'php-mode
	  mode-name "Php"
	  c++-mode-hook current-c++-mode-hook)
    (run-hooks 'php-mode-hook)))

(setq c-indent-level 4)

;;; Complete an imcomplete php function name
(defun php-complete-symbol ()
  (interactive)
  (let* ((end (point))
         (beg (save-excursion
                (backward-sexp 1)
                (while (= (char-syntax (following-char)) ?\')
                  (forward-char 1))
                (point)))
         (pattern-orig (buffer-substring beg end))
         (pattern (downcase pattern-orig))
         (completion (try-completion pattern php-alist))
	 completion-next)
    (setq php-last-pattern pattern)
    (cond ((eq completion t)
	   (let ((comp (cdr (assoc pattern php-alist))))
	     (delete-region beg end)
	     (insert comp)
	     (and php-auto-describe (php-describe-function comp))
	     )
	   )
          ((null completion)
           (message "Can't find completion for \"%s\"" pattern)
           (ding))
          ((not (string= pattern completion))
           (delete-region beg end)
	   (insert (if (eq (try-completion completion php-alist) t)
		       (cdr (assoc completion php-alist))
		     completion))
	   )
          (t
           (message "Making completion list...")
           (let ((list (all-completions pattern php-alist)))
             (with-output-to-temp-buffer "*Help*"
               (display-completion-list list)))
           (message "Making completion list...%s" "done")))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; show manual

(defun php-describe-function (&optional arg)
  (interactive)
  (let* ((fn (get-one-word))
	 (val (or arg
		  (completing-read
		   (if fn
		       (format "Describe php function (default %s): " fn)
		     "Describe function: ") php-alist)))
	 )
    (setq function (if (equal val "")
		       fn val)))
  (let ((target1 (format "^%s[( ]" function))
	(help-buffer php-help-buffer-name))
    (if (one-window-p)
	(split-window))
    (select-window (or (get-buffer-window help-buffer)
		       (next-window)))
    (switch-to-buffer (php-prepare-document-buffer))
    (use-local-map describe-php-mode-map)
    (goto-char (point-min))
    (if (re-search-forward target1 nil t 1)
	(progn
	  (beginning-of-line)
	  (set-window-start (selected-window) (point)))
      (progn
	(princ "No match !")))))


(defvar describe-php-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map " " 'scroll-up)
    (define-key map "\177" 'scroll-down)
    (define-key map "<" 'beginning-of-buffer)
    (define-key map ">" 'end-of-buffer)
    (define-key map "1" 'delete-other-windows)
    (define-key map "?" 'describe-mode)
    (define-key map "h" 'describe-mode)
    (define-key map "w" 'php-describe-function)
    (define-key map "q" 'describe-quit)
    map))

(defun describe-quit ()
  (interactive)
  (kill-buffer (current-buffer))
  (if (not (one-window-p))
      (delete-window)))

(defun get-one-word (&optional re)
  (interactive)
  (let* ((target (or re "a-zA-Z0-9:\-_"))
	 (end (save-excursion
		(skip-chars-forward target)
		(point)))
	 (beg (save-excursion 
		(skip-chars-backward target)
		(point))))
    (buffer-substring beg end)))

(defun php-prepare-document-buffer ()
  (let ((tmp-buffer (get-buffer php-help-buffer-name)))
    (if tmp-buffer 
	(set-buffer tmp-buffer)
      (setq tmp-buffer (generate-new-buffer php-help-buffer-name))
      (set-buffer tmp-buffer)
      (insert-file-contents php-document-file)
      (setq buffer-read-only t)
      )
    tmp-buffer
    )
  )

(defun php-eval-region ()
  (interactive)
  (if (> (point) (mark)) 
      (exchange-point-and-mark))
  (let* ((beg-point (point))
	 (end-point (mark)))
    (call-process-region beg-point end-point php-prog-cgi nil t t php-prog-cgi-arg)
    ))

(defun php-get-alist ()
  (interactive)
  (let ((a-php-alist nil)
	word)
    (php-prepare-document-buffer)
    (goto-char (point-min))
    (message "Making php-alist...")
    (while (re-search-forward "^[a-zA-Z_0-9]+" nil t)
      (setq word (buffer-substring (match-beginning 0) (match-end 0)))
      (setq a-php-alist (cons  (cons (downcase word) word) a-php-alist))
      )
    (message "Making php-alist...done")
    a-php-alist
    )
  )
