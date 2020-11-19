(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  (when no-ssl
    (warn "\
Your version of Emacs does not support SSL connections,
which is unsafe because it allows man-in-the-middle attacks.
There are two things you can do about this warning:
1. Install an Emacs version that does support SSL and be safe.
2. Remove this warning from your init file so you won't see it again."))
  ;; Comment/uncomment these two lines to enable/disable MELPA and MELPA Stable as desired
  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  (add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
  (when (< emacs-major-version 24)
    ;; For important compatibility libraries like cl-lib
    (add-to-list 'package-archives (cons "gnu" (concat proto "://elpa.gnu.org/packages/")))))

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(add-to-list 'load-path "~/.emacs.d/lisp")
(let ((default-directory  "~/.emacs.d/lisp"))
  (normal-top-level-add-subdirs-to-load-path))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("2809bcb77ad21312897b541134981282dc455ccd7c14d74cc333b6e549b824f3" "7f1d414afda803f3244c6fb4c2c64bea44dac040ed3731ec9d75275b9e831fe5" "0fffa9669425ff140ff2ae8568c7719705ef33b7a927a0ba7c5e2ffcfac09b75" default)))
 '(package-selected-packages
   (quote
    (rtags-xref flycheck-rtags company-rtags helm-rtags rtags go-dlv godoctor go-eldoc company-anaconda company-go aggressive-indent rainbow-mode rainbow-delimiters smartparens ivy-hydra counsel ivy smex use-package-chords crux dap-mode lsp-java lsp-mode auto-complete highlight-symbol yaml-mode whole-line-or-region exec-path-from-shell go-mode magit helm dracula-theme))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


;; shortcut to edit emacs config file
(defun find-config ()
  "Edit config.org"
  (interactive)
  (find-file "~/.emacs"))
(global-set-key (kbd "C-c I") 'find-config)

;; bootstrap use-package
(package-refresh-contents)
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(load-theme 'manoj-dark)

;; centralize the backup files that are created
(setq backup-directory-alist '(("." . "~/.emacs.d/backup"))
  backup-by-copying t    ; Don't delink hardlinks
  version-control t      ; Use version numbers on backups
  delete-old-versions t  ; Automatically delete excess backups
  kept-new-versions 20   ; how many of the newest versions to keep
  kept-old-versions 5    ; and how many of the old
)

;;crux has useful functions extracted from Emacs Prelude. Set C-a to move to the first non-whitespace character on a line, and then to toggle between that and the beginning of the line.
(use-package crux
  :ensure t
  :bind (("C-a" . crux-move-beginning-of-line)))

;; I never want whitespace at the end of lines. Remove it on save.
(add-hook 'before-save-hook 'delete-trailing-whitespace)


;;Key chords
;;Key chords let us bind functions to sequential key presses like jj. It makes evil mode being turned off much more palatable.
(use-package use-package-chords
  :ensure t
  :config
  (key-chord-mode 1))

;;We bind individual mode chords via use-package but some globals are useful like JJ to jump to the previous buffer.
(defun jc/switch-to-previous-buffer ()
  "Switch to previously open buffer.
Repeated invocations toggle between the two most recently open buffers."
  (interactive)
  (switch-to-buffer (other-buffer (current-buffer) 1)))

(key-chord-define-global "JJ" 'jc/switch-to-previous-buffer)

;; Command completion
;; smart M-x suggests M-x commands based on recency and frequency. I don't tend to use it directly but counsel uses it to order suggestions.
(use-package smex
   :ensure t)

;;ivy is a generic completion framework which uses the minibuffer. Turning on ivy-mode enables replacement of lots of built in ido functionality.
(use-package ivy
    :ensure t
    :diminish ivy-mode
    :config
    (ivy-mode t))

;; By default ivy starts filters with ^. I don't normally want that and can easily type it manually when I do.

  (setq ivy-initial-inputs-alist nil)

;; counsel is a collection of ivy enhanced versions of common Emacs commands. I haven't bound much as ivy-mode takes care of most things.
(use-package counsel
  :ensure t
  :bind (("M-x" . counsel-M-x))
  :chords (("yy" . counsel-yank-pop)))

;; swiper is an ivy enhanced version of isearch.
(use-package swiper
  :ensure t
  :bind (("M-s" . swiper)))

;; hydra presents menus for ivy commands.
(use-package ivy-hydra
  :ensure t)

;; Suggest next key
;; Suggest next keys to me based on currently entered key combination.
(use-package which-key
  :ensure t
  :diminish which-key-mode
  :config
  (add-hook 'after-init-hook 'which-key-mode))

;; Navigation
;; One of the most important features of an advanced editor is quick text navigation. avy let's us jump to any character or line quickly.
(use-package avy
  :ensure t
  :chords (("jj" . avy-goto-char-2)
           ("jl" . avy-goto-line)))

;; (use-package apropospriate-theme
;;   :ensure t
;;   :config
;;   (load-theme 'apropospriate-dark t)

;; Display pretty symbols for things like lambda.

(setq prettify-symbols-unprettify-at-point 'right-edge)
(global-prettify-symbols-mode 0)

(add-hook
 'python-mode-hook
 (lambda ()
   (mapc (lambda (pair) (push pair prettify-symbols-alist))
         '(("def" . "𝒇")
           ("class" . "𝑪")
           ("and" . "∧")
           ("or" . "∨")
           ("not" . "￢")
           ("in" . "∈")
           ("not in" . "∉")
           ("return" . "⟼")
           ("yield" . "⟻")
           ("for" . "∀")
           ("!=" . "≠")
           ("==" . "＝")
           (">=" . "≥")
           ("<=" . "≤")
           ("[]" . "⃞")
           ("=" . "≝")))))
;; Powerline is a port from vim, and improves the modeline. Without specifying powerline-default-separator the separators don't show correctly for me.
(use-package powerline
  :disabled
  :ensure t
  :config
  (setq powerline-default-separator 'utf-8))

;; When programming I like my editor to try to help me with keeping parentheses balanced.
(use-package smartparens
  :ensure t
  :diminish smartparens-mode
  :config
  (add-hook 'prog-mode-hook 'smartparens-mode))
  (setq sp-escape-quotes-after-insert nil)

;; Highlight parens etc. for improved readability.
(use-package rainbow-delimiters
  :ensure t
  :config
  (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))

;; Highlight strings which represent colours. I only want this in programming modes, and I don't want colour names to be highlighted (x-colors).
(use-package rainbow-mode
  :ensure t
  :config
  (setq rainbow-x-colors nil)
  (add-hook 'prog-mode-hook 'rainbow-mode))

;; Keep things indented correctly for me.
(use-package aggressive-indent
    :ensure t)

;; Expand parentheses for me.
(add-hook 'prog-mode-hook 'electric-pair-mode)

;; Projectile handles folders which are in version control.
(use-package projectile
  :ensure t
  :config
  (projectile-mode))

;; Tell projectile to integrate with ivy for completion.
(setq projectile-completion-system 'ivy)

;; Add some extra completion options via integration with counsel. In particular this enables C-c p SPC for smart buffer / file search, and C-c p s s for search via ag.

;; There is no function for projectile-grep, but we could use counsel-git-grep which is similar. Should I bind that to C-c p s g?
(use-package counsel-projectile
  :ensure t
  :config
  (add-hook 'after-init-hook 'counsel-projectile-mode))

;; Fuzzy search
;; fzf is a fuzzy file finder which is very quick.
(use-package fzf
  :ensure t)

;; Display line changes in gutter based on git history. Enable it everywhere.
(use-package git-gutter
  :ensure t
  :config
  (global-git-gutter-mode 't)
  :diminish git-gutter-mode)

;; TimeMachine lets us step through the history of a file as recorded in git.
(use-package git-timemachine
  :ensure t)

(use-package lsp-mode
  :init (setq lsp-keymap-prefix "C-l")
  :ensure t
  :commands (lsp lsp-deferred)
  :hook (go-mode . lsp-deferred)
  (lsp-mode . lsp-enable-which-key-integration))
(setq lsp-enable-file-watchers nil)
(setq lsp-response-timeout 30)

;; Set up before-save hooks to format buffer and add/delete imports.
;; Make sure you don't have other gofmt/goimports hooks enabled.
(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)

;; Optional - provides fancier overlays.
(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode)

;; Autocomplete
;; Company mode provides good autocomplete options. Perhaps I should add company-quickhelp for documentation (https://github.com/expez/company-quickhelp)?

;; It would also be good to improve integration with yasnippet as I don't feel I'm making the best use there.

(use-package company
  :ensure t
  :diminish
  :config
  (add-hook 'after-init-hook 'global-company-mode)

  (setq company-idle-delay t)

  (use-package company-go
    :ensure t
    :config
    (add-to-list 'company-backends 'company-go))

  (use-package company-anaconda
    :ensure t
    :config
    (add-to-list 'company-backends 'company-anaconda)))

;; company-lsp integrates company mode completion with lsp-mode.
;; completion-at-point also works out of the box but doesn't support snippets.
  (use-package company-lsp
    :ensure t
    :commands company-lsp)

;; I don't want suggestions from open files / buffers to be automatically lowercased as these are often camelcase function names.
(setq company-dabbrev-downcase nil)

;; Snippets
;; Unlike autocomplete which suggests words / symbols, snippets are pre-prepared templates which you fill in.

;; I'm using a community library ([[https://github.com/AndreaCrotti/yasnippet-snippets]]) with lots of ready made options, and have my own directory of custom snippets I've added. Not sure if I should unify these by forking yasnippet-snippets.

;; Type the shortcut and press TAB to complete, or M-/ to autosuggest a snippet.
(use-package yasnippet
    :ensure t
    :diminish yas-minor-mode
    :config
    (add-to-list 'yas-snippet-dirs "~/.emacs.d/yasnippet-snippets")
    (add-to-list 'yas-snippet-dirs "~/.emacs.d/snippets")
    (yas-global-mode)
    (global-set-key (kbd "M-/") 'company-yasnippet))

;; Markdown
;; Markdown support isn't built into Emacs, add it with markdown-mode.
(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))

;; Golang
;; Go-mode provides basic language support, we call gofmt on each save to keep code tidy, use eldoc to display documentation and add guru / doctor for IDE functionality.
(use-package go-mode
  :ensure t
  :config
  (add-hook 'before-save-hook 'gofmt-before-save)

  (use-package go-eldoc
    :ensure t
    :config
    (add-hook 'go-mode-hook 'go-eldoc-setup))

  (use-package godoctor
    :ensure t)

  (use-package go-guru
    :ensure t)

  (use-package go-dlv
    :ensure t))

;; Go guru needs a scope to look at, this function sets it to the current package.
(defun jc/go-guru-set-current-package-as-main ()
  "GoGuru requires the scope to be set to a go package which
   contains a main, this function will make the current package the
   active go guru scope, assuming it contains a main"
  (interactive)
  (let* ((filename (buffer-file-name))
         (gopath-src-path (concat (file-name-as-directory (go-guess-gopath)) "src"))
         (relative-package-path (directory-file-name (file-name-directory (file-relative-name filename gopath-src-path)))))
    (setq go-guru-scope relative-package-path)))

(require 'go-mode)
  (add-hook 'before-save-hook 'gofmt-before-save)

(when (version<= "26.0.50" emacs-version )
  (global-display-line-numbers-mode))

(require 'highlight-symbol)
  (global-set-key [(control f3)] 'highlight-symbol)
  (global-set-key [f3] 'highlight-symbol-next)
  (global-set-key [(shift f3)] 'highlight-symbol-prev)
  (global-set-key [(meta f3)] 'highlight-symbol-query-replace)

(require 'magit)
  (global-set-key (kbd "C-x g") 'magit-status)

;; TODO Fix this
;; (global-set-key (kbd "C-d f") 'ediff-files)

(add-hook 'go-mode-hook 'lsp-deferred)

;;enable company mode in all buffers
(add-hook 'after-init-hook 'global-company-mode)
(add-hook 'go-mode-hook #'go-guru-hl-identifier-mode)

;; save history
(savehist-mode 1)
;; remember cursor position, for emacs 25.1 or later
(save-place-mode 1)

(dap-mode 1)
(dap-ui-mode 1)
;; enables mouse hover support
(dap-tooltip-mode 1)
;; use tooltips for mouse hover
;; if it is not enabled `dap-mode' will use the minibuffer.
(tooltip-mode 1)
(add-hook 'dap-stopped-hook
          (lambda (arg) (call-interactively #'dap-hydra)))


(require 'helm)
(require 'helm-config)

;; The default "C-x c" is quite close to "C-x C-c", which quits Emacs.
;; Changed to "C-c h". Note: We must set "C-c h" globally, because we
;; cannot change `helm-command-prefix-key' once `helm-config' is loaded.
(global-set-key (kbd "C-c h") 'helm-command-prefix)
(global-unset-key (kbd "C-x c"))

(define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebind tab to run persistent action
(define-key helm-map (kbd "C-i") 'helm-execute-persistent-action) ; make TAB work in terminal
(define-key helm-map (kbd "C-z")  'helm-select-action) ; list actions using C-z

(when (executable-find "curl")
  (setq helm-google-suggest-use-curl-p t))

(setq helm-split-window-in-side-p           t ; open helm buffer inside current window, not occupy whole other window
      helm-move-to-line-cycle-in-source     t ; move to end or beginning of source when reaching top or bottom of source.
      helm-ff-search-library-in-sexp        t ; search for library in `require' and `declare-function' sexp.
      helm-scroll-amount                    8 ; scroll 8 lines other window using M-<next>/M-<prior>
      helm-ff-file-name-history-use-recentf t
      helm-echo-input-in-header-line t)

(defun spacemacs//helm-hide-minibuffer-maybe ()
  "Hide minibuffer in Helm session if we use the header line as input field."
  (when (with-helm-buffer helm-echo-input-in-header-line)
    (let ((ov (make-overlay (point-min) (point-max) nil nil t)))
      (overlay-put ov 'window (selected-window))
      (overlay-put ov 'face
                   (let ((bg-color (face-background 'default nil)))
                     `(:background ,bg-color :foreground ,bg-color)))
      (setq-local cursor-type nil))))


(add-hook 'helm-minibuffer-set-up-hook
          'spacemacs//helm-hide-minibuffer-maybe)

(setq helm-autoresize-max-height 0)
(setq helm-autoresize-min-height 20)
(helm-autoresize-mode 1)

(helm-mode 1)


;;(require 'req-package)

(use-package rtags
  :config
  (progn
    (unless (rtags-executable-find "rc") (error "Binary rc is not installed!"))
    (unless (rtags-executable-find "rdm") (error "Binary rdm is not installed!"))

    (define-key c-mode-base-map (kbd "M-.") 'rtags-find-symbol-at-point)
    (define-key c-mode-base-map (kbd "M-,") 'rtags-location-stack-back)
    (define-key c-mode-base-map (kbd "M-?") 'rtags-find-all-references-at-point)
    (rtags-enable-standard-keybindings)

    (setq rtags-use-helm t)

    ;; Shutdown rdm when leaving emacs.
    (add-hook 'kill-emacs-hook 'rtags-quit-rdm)
    ))

;; TODO: Has no coloring! How can I get coloring?
(use-package helm-rtags
  :config
  (progn
    (setq rtags-display-result-backend 'helm)
    ))

;; Use rtags for auto-completion.
(use-package company-rtags
  :config
  (progn
    (setq rtags-autostart-diagnostics t)
    (rtags-diagnostics)
    (setq rtags-completions-enabled t)
    (push 'company-rtags company-backends)
    ))

;; Live code checking.
(use-package flycheck-rtags
  :config
  (progn
    ;; ensure that we use only rtags checking
    ;; https://github.com/Andersbakken/rtags#optional-1
    (defun setup-flycheck-rtags ()
      (flycheck-select-checker 'rtags)
      (setq-local flycheck-highlighting-mode nil) ;; RTags creates more accurate overlays.
      (setq-local flycheck-check-syntax-automatically nil)
      (rtags-set-periodic-reparse-timeout 2.0)  ;; Run flycheck 2 seconds after being idle.
      )
    (add-hook 'c-mode-hook #'setup-flycheck-rtags)
    (add-hook 'c++-mode-hook #'setup-flycheck-rtags)
    ))

(defun astyle-this-buffer (pmin pmax)
  (interactive "r")
  (shell-command-on-region pmin pmax
                           "astyle --pad-oper --pad-paren-in" ;; add options here...
                           (current-buffer) t
                           (get-buffer-create "*Astyle Errors*") t))

(setq auto-save-default nil)
(global-auto-revert-mode t)
(setq x-select-enable-clipboard t)

(require 'rtags)
(cmake-ide-setup)
(add-hook 'c-mode-hook 'rtags-start-process-unless-running)
(add-hook 'c++-mode-hook 'rtags-start-process-unless-running)

(use-package rtags
  :ensure t
  :hook (c++-mode . rtags-start-process-unless-running)
  :config (setq rtags-completions-enabled t
		rtags-path "/home/vareti/.emacs.d/elpa/rtags-20200221.36/rtags.el"
		rtags-rc-binary-name "/home/vareti/bin/rc"
		rtags-use-helm t
		rtags-rdm-binary-name "/home/vareti/bin/rdm")
  :bind (("C-c E" . rtags-find-symbol)
  	 ("C-c e" . rtags-find-symbol-at-point)
  	 ("C-c O" . rtags-find-references)
  	 ("C-c o" . rtags-find-references-at-point)
  	 ("C-c s" . rtags-find-file)
  	 ("C-c v" . rtags-find-virtuals-at-point)
  	 ("C-c F" . rtags-fixit)
  	 ("C-c f" . rtags-location-stack-forward)
  	 ("C-c b" . rtags-location-stack-back)
  	 ("C-c n" . rtags-next-match)
  	 ("C-c p" . rtags-previous-match)
  	 ("C-c P" . rtags-preprocess-file)
  	 ("C-c R" . rtags-rename-symbol)
  	 ("C-c x" . rtags-show-rtags-buffer)
  	 ("C-c T" . rtags-print-symbol-info)
  	 ("C-c t" . rtags-symbol-type)
  	 ("C-c I" . rtags-include-file)
  	 ("C-c i" . rtags-get-include-file-for-symbol)))

(setq rtags-display-result-backend 'helm)
