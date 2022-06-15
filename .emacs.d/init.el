;;; -*- lexical-binding: t -*-

(eval-and-compile
  (when (or load-file-name byte-compile-current-file)
    (setq user-emacs-directory
          (expand-file-name
           (file-name-directory (or load-file-name byte-compile-current-file))))))

(eval-and-compile
  (customize-set-variable
   'package-archives '(("melpa" . "https://melpa.org/packages/")
                       ("gnu"   . "https://elpa.gnu.org/packages/")))
  (package-initialize)
  (unless (package-installed-p 'leaf)
    (package-refresh-contents)
    (package-install 'leaf))

  (leaf leaf-keywords
    :ensure t
    :init
    ;; optional packages if you want to use :hydra, :el-get, :blackout,,,
    (leaf hydra :ensure t)
    (leaf el-get :ensure t)
    (leaf blackout :ensure t)

    :config
    ;; initialize leaf-keywords.el
    (leaf-keywords-init)))

;; ここにいっぱい設定を書く
(leaf leaf
  :ensure t
  :config
  (leaf leaf-convert
    :ensure t
    :config (leaf use-package :ensure t))) 

(leaf cus-edit
  ;; this leaf is related to no package,
  ;; so there's nothing to eval-after-load.
  :leaf-defer nil
  :doc "tools for customizing Emacs and Lisp packages"
  :tag "builtin" "faces" "help"
  :custom `((custom-file . ,(locate-user-emacs-file "custom-dump.el"))))

(leaf global-custom
  ;; this leaf is related to no package,
  ;; so there's nothing to eval-after-load.
  :leaf-defer nil
  :custom
  (mac-option-modifier . '(:ordinary meta :function meta :mouse meta))
  :config
  (tool-bar-mode -1)
  (global-visual-line-mode)
  (global-display-line-numbers-mode))

(leaf exec-path-from-shell
  :when (memq window-system '(mac ns x))
  :ensure t
  :config (exec-path-from-shell-initialize))

(leaf dired
  ;; this leaf is related to no package,
  ;; so there's nothing to eval-after-load.
  :leaf-defer nil
  :config
  ;; make sure run-time evaluation of lsprog; not compile-time.
  (let ((lsprog (or (executable-find "gls") (executable-find "ls"))))
    (leaf dired-custom
      :custom (insert-directory-program . lsprog))))

(leaf company
  :ensure t)

(leaf flycheck
  :ensure t)

(leaf highlight-indent-guides
  :ensure t
  :blackout t
  :hook (((prog-mode-hook yaml-mode-hook) . highlight-indent-guides-mode))
  :custom (
           (highlight-indent-guides-method . 'bitmap)
           (highlight-indent-guides-auto-enabled . t)
           (highlight-indent-guides-responsive . t)))

(leaf which-key
  :ensure t
  :config
  (which-key-mode))

(leaf lsp-mode
  :ensure t
  :commands lsp-enable-which-key-integration lsp
  :custom
  (lsp-keymap-prefix . "C-c l")
  :init
  (leaf lsp-enable-which-key-integration
    :when (package-installed-p 'which-key)
    :hook ((lsp-mode-hook . lsp-enable-which-key-integration)))
  (leaf lsp-ui
    :ensure t
    :commands lsp-ui-mode)
  (leaf helm-lsp
    :disabled t
    :commands helm-lsp-workspace-symbol)
  (leaf lsp-ivy
    :disabled t
    :commands lsp-ivy-workspace-symbol)
  (leaf lsp-treemacs
    :disabled t
    :commands lsp-treemacs-errors-list))

(leaf haskell-mode
  :ensure t
  :init
  (leaf lsp-haskell
    :when (package-installed-p 'lsp-mode)
    :ensure t
    :hook (haskell-mode-hook . lsp)))

(leaf org-mode
  :hook ((org-mode-hook . org-indent-mode)))

(leaf auctex
  :ensure t
  :init
  (leaf auctex-cluttex
    :ensure t)
  :custom
  (TeX-parse-self . t) ; Enable parse on load.
  (TeX-auto-save . t) ; Enable parse on save.
  )

(leaf yaml-mode
  :ensure t)

(leaf python
  :init
  (leaf lsp-pyright
    :when (package-installed-p 'lsp-mode)
    :ensure t
    :hook
    (python-mode-hook . (lambda () (require 'lsp-pyright)
                          (lsp))))
  (leaf poetry
    :ensure t)
  )

(leaf magit
  :ensure t
  :config
  (leaf magit-ssh-agent
    :preface
    (defvar my-magit-ssh-agent-existing nil)
    (defun my-register-local-sshagent-for-magit nil
      (let ((ssh-executable (executable-find "ssh-agent")))
        (unless my-magit-ssh-agent-existing
          (with-temp-buffer
            (call-process ssh-executable nil '(t t))
            (goto-char 1)
            (while (re-search-forward "^\\(SSH_[^=]+\\)=\\([^;]+\\)" nil t)
              (setenv (match-string 1) (match-string 2))))
          (setenv "GIT_SSH_COMMAND" "ssh -o AddKeysToAgent=yes")
          (setq my-magit-ssh-agent-existing t)
          (add-hook
           'kill-emacs-hook
	   `(lambda nil
              (call-process ,ssh-executable nil nil nil "-k"))))))
    :defun my-register-local-sshagent-for-magit
    :custom (transient-default-level . 7)
    :hook
    ((magit-credential-hook . my-register-local-sshagent-for-magit))))

(provide 'init)

;; Local Variables:
;; indent-tabs-mode: nil
;; End:

;;; init.el ends here
