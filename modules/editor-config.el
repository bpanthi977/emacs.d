(setq exec-path (append '("/home/bpanthi/.local/bin") exec-path))

(use-package emojify
  :ensure t
  :defer t)

;; Newline at end of file
(setq require-final-newline t)
;; delete the selection with a keypress
(delete-selection-mode t)
;; Backup and autosave files
(setq backup-directory-alist
      `(("." . ,(concat savefile-dir "/backups"))))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))
(setq auto-save-list-file-prefix
      (concat savefile-dir "/auto-save-list/.saves-"))
;; revert buffers automatically when underlying files are changed externally
(global-auto-revert-mode t)
;; smart tab behavior - indent or complete
(setq-default tab-always-indent 't)
(setq-default tab-width 8)
(setq tab-width 8)


(setq-default indent-tabs-mode t)
;; disable annoying blink-matching-paren
(setq blink-matching-paren nil)
(show-paren-mode t)

;; meaningful names for buffers with the same name
(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)
(setq uniquify-separator "/")
(setq uniquify-after-kill-buffer-p t)    ; rename after killing uniquified
(setq uniquify-ignore-buffers-re "^\\*") ; don't muck with special buffers

;; save point position in buffers
(require 'saveplace)
(setq save-place-file (expand-file-name "saveplace" savefile-dir))
(save-place-mode t)


;; save recent files
(use-package recentf
  :ensure t
  :demand t 
  :init
  (setq recentf-save-file (expand-file-name "recentf" savefile-dir)
	recentf-max-saved-items 500
	recentf-max-menu-items 15
	;; disable recentf-cleanup on Emacs start, because it can cause
	;; problems with remote files
	recentf-auto-cleanup 'never)
  (recentf-mode +1))

;; highlight the current line
(global-hl-line-mode +1)
;; Don't save last deleted region or rectangle to register 0
(setf cua-delete-copy-to-register-0 nil)
;; Truncate lines
(setq-default truncate-lines t)

;;smart pairing for all
(use-package smartparens
  :ensure t
  :defer nil
  :config
  :bind (;; Movement [see: https://ebzzry.io/en/emacs-pairs/]
	 ( "C-M-f" . sp-forward-sexp)
	 ( "C-M-b" . sp-backward-sexp)
	 ( "C-M-a" . sp-beginning-of-sexp)
	 ( "C-M-e" . sp-end-of-sexp)
	 
	 ;; transpose, kill, copy
	 ( "C-M-t" . sp-transpose-sexp)
	 ( "C-M-k" . sp-kill-sexp)
	 ( "C-M-w" . sp-copy-sexp)
	 
	 ;; wrapping, unwraping
	 ( "M-(" . sp-wrap-round)
	 ( "M-[" . sp-wrap-square)
	 ( "M-\"" . sp-wrap-quote)
	 ( "M-<backspace>" . sp-backward-unwrap-sexp)
	 
	 ;; slurping and barfing 
	 ( "C-<right>" . sp-forward-slurp-sexp)
	 ( "C-<left>" . sp-forward-barf-sexp)

	 ;; ( "M-D" . sp-splice-sexp)
	 ;; ( "C-M-<delete>" . sp-splice-sexp-killing-forward)
	 ;; ( "C-M-<backspace>" . sp-splice-sexp-killing-backward)
	 ;; ( "C-S-<backspace>" . sp-splice-sexp-killing-around)

	 ;; ( "C-]" . sp-select-next-thing-exchange)
	 ;; ( "C-<left_bracket>" . sp-select-previous-thing)
	 ;; ( "C-M-]" . sp-select-next-thing)

	 ;; ;;		 ( "M-F" . sp-forward-symbol)
	 ;; ;;		 ( "M-B" . sp-backward-symbol)

	 ;; ( "C-\"" . sp-change-inner)
	 ( "M-i" . sp-change-enclosing))
  :hook ((prog-mode . smartparens-mode))
  :init
  (require 'smartparens-config)
  (smartparens-global-strict-mode -1)
  (defun sp-wrap-quote ()
    (interactive)
    (sp-wrap-with-pair "\""))
  (setq sp-autoskip-closing-pair nil)
  (setq sp-hybrid-kill-entire-symbol nil))

(defun sudo-edit (&optional arg)
  "Edit currently visited file as root.

With a prefix ARG prompt for a file to visit.
Will also prompt for a file to visit if current
buffer is not visiting a file."
  (interactive "P")
  (if (or arg (not buffer-file-name))
      (find-file (concat "/sudo:root@localhost:"
                         (ido-read-file-name "Find file(as root): ")))
    (find-alternate-file (concat "/sudo:root@localhost:" buffer-file-name))))

;; Projectile
(use-package projectile
  :ensure t
  :defer t
  :config
  (require 'counsel-projectile)
  :init 
  (setq projectile-indexing-method 'alien)
  (setq projectile-enable-caching t)
  (setq projectile-cache-file (concat init-dir "cache/projectile.cache")
	projectile-known-projects-file (concat savefile-dir "/projectile-bookmarks.eld"))
  :bind-keymap ("M-P" . projectile-command-map))

(use-package counsel-projectile
  :ensure t
  :defer t 
  :config
  (counsel-projectile-mode 1))

;; Ace Window
(use-package ace-window
  :ensure t
  :init
  (require 'winner)
  (winner-mode t)
  (setf aw-dispatch-always t)
  (setq aw-keys '(?a ?s ?d ?f ?j ?k ?l))
  (smartrep-define-key bp/global-prefix-map
      "w"
    '(("o" . other-window)
      ("w" . ace-window)
      ("D" . delete-window)
      ("k" . kill-buffer-and-window)
      ("d" . ace-delete-window)
      ("u" . winner-undo)
      ("r" . winner-redo)))
  
  (bind-keys :map bp/global-prefix-map 
	   ("w n" . make-frame)))

(use-package yasnippet
  :ensure t
  :defer t 
  :preface
  (defun company-mode/backend-with-yas (backend)
    (if (and (listp backend) (member 'company-yasnippet backend))
	backend
      (append (if (consp backend) backend (list backend))
	      '(:with company-yasnippet))))

  :after (yasnippet-snippets company-yasnippet)
  :config
  (add-to-list 'company-backends 'company-yasnippet)
  (setq company-backends (mapcar #'company-mode/backend-with-yas company-backends)))

(use-package markdown-mode
  :ensure t
  :defer t
  :mode "\\.md\\'"
  :config 
  (setf markdown-command "/home/bpanthi/.local/bin/pandoc -f gfm"))

(global-set-key (kbd "M-.") 'find-function-at-point)

;; Tramp
(setq tramp-persistency-file-name (concat init-dir "cache/tramp"))
;; Abbrev 
(setq abbrev-file-name (concat savefile-dir "/abbrev_defs"))

;; Magit
(use-package magit
  :ensure t
  :defer t
  :init 
  (setf transient-history-file (concat savefile-dir "/transient/history.el")))

;; Avy
(use-package avy
  :ensure t
  :defer t 
  :bind (:map bp/global-prefix-map
	      ("g g" . bp/avy-goto-char-end)
	      ("g c" . avy-goto-char)
	      ("g s" . avy-goto-char-timer)
	      ("g l" . avy-goto-line))
  :config
  (defun bp/avy-goto-char-end ()
    (interactive)
    (when (avy-goto-char-timer)
      (forward-char 1)))
  (setf avy-timeout-seconds 0.3))

(use-package god-mode
  :ensure t
  :defer t 
  :bind (("M-q" . god-mode-all)
	 :map bp/global-prefix-map
	 ("q" . god-local-mode))
  :config
  (define-key god-local-mode-map (kbd ".") #'repeat)

  (defun my-update-cursor ()
    (setq cursor-type (if (or god-local-mode buffer-read-only)
			  'bar
			'box)))

  (add-hook 'god-mode-enabled-hook 'my-update-cursor )
  (add-hook 'god-mode-disabled-hook 'my-update-cursor))

;; This interfered with company completion display
;; (use-package fill-column-indicator
;;   :ensure t
;;   :config
;;   (fci-mode t))

;; (use-package unicode-math-input
;;   :ensure t
;;   :defer t)


;; spell checking
(use-package ispell
  :ensure t
  :defer t
  :commands (ispell ispell-buffer)
  :init 
  (setq ispell-program-name "hunspell")
  (bind-keys :map bp/global-prefix-map
	     ("e i i" . ispell)
	     ("e i w" . ispell-word)
	     ("e i c" . ispell-continue)))

(use-package flyspell
  :ensure t
  :demand nil
  :config
  (setq flyspell-issue-message-flag nil))

(use-package multiple-cursors
  :ensure t
  :defer t
  :commands (mc/mark-previous-like-this mc/mark-next-like-this)
  :init
  (smartrep-define-key bp/global-prefix-map
      "m"
    '(("p" . mc/mark-previous-like-this)
      ("n" . mc/mark-next-like-this))))

(use-package expand-region
  :ensure t
  :defer t 
  :bind (("C--" . er/contract-region)
	 ("C-=" . er/expand-region)))

(use-package unfill
  :ensure t
  :bind (:map bp/global-prefix-map
	      ("e u" . unfill-paragraph))
  :commands (unfill-paragraph unfill-toggle unfill-region))

(add-hook 'text-mode-hook (lambda ()
			    (visual-line-mode t)))


;; (use-package origami
;;   :ensure t
;;   :defer t
;;   :init
;;   (smartrep-define-key bp/global-prefix-map ";"
;; 	'((";" . origami-recursively-toggle-node)
;; 	  ("a" . origami-show-only-node)
;; 	  ("o" . origami-open-all-nodes)
;; 	  ("c" . origami-close-all-nodes)
;; 	  ("u" . origami-undo)
;; 	  ("r" . origami-redo))))

;; (use-package discover
;;   :ensure t
;;   :demand t
;;   :init
;;   (global-discover-mode 1))

;; Dired
(use-package dired
  :config 
  (defun dired-open-file ()
    "In dired, open the file named on this line."
    (interactive)
    (let* ((file (dired-get-filename nil t)))
      (call-process "xdg-open" nil 0 nil file)))

  (define-key dired-mode-map (kbd "C-c o") 'dired-open-file))

(use-package outshine
  :ensure t 
  :defer t)

;; (use-package hyperbole 
;;   :ensure t 
;;   :defer nil
;;   :config 
;;   (require 'hyperbole)
;;   (global-set-key (kbd "<S-down-mouse-1>") #'action-key-depress-emacs)
;;   (global-set-key (kbd "<S-mouse-1>") #'action-mouse-key-emacs)
;;   (global-set-key (kbd "<C-S-down-mouse-1>") #'mouse-appearance-menu) )


(use-package easy-kill
  :ensure t
  :config
  (global-set-key [remap kill-ring-save] #'easy-kill)
  (global-set-key [remap mark-sexp] #'easy-mark))
