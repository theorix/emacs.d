(add-hook 'comint-output-filter-functions 'comint-watch-for-password-prompt)

(global-set-key "\M-p"  'bs-cycle-previous)
(global-set-key "\M-n"  'bs-cycle-next)
(set-face-foreground 'highlight "white")
(set-face-background 'highlight "blue")
(set-face-foreground 'region "cyan")
(set-face-background 'region "blue")
(set-face-foreground 'secondary-selection "skyblue")
(set-face-background 'secondary-selection "darkblue")
(set-foreground-color "grey")
(set-background-color "black")
(set-cursor-color "gold1")
(set-mouse-color "gold1")
;;设置标题
(setq frame-title-format
      '("- Emacs  -   [ " (buffer-file-name "%f \]"
                                            (dired-directory dired-directory "%b \]"))))
;;设置启动大小
(set-frame-size (selected-frame) 170 44)
(setq inhibit-startup-message t);关闭起动时LOGO
(setq visible-bell t);关闭出错时的提示声
(setq default-major-mode 'erlang-mode)  ;一打开就起用 text 模式
(global-font-lock-mode t);语法高亮
(auto-image-file-mode t);打开图片显示功能
(fset 'yes-or-no-p 'y-or-n-p);以 y/n代表 yes/no
(column-number-mode t);显示列号
(show-paren-mode t);显示括号匹配
(setq mouse-yank-at-point t);支持中键粘贴
(transient-mark-mode t);允许临时设置标记
(setq x-select-enable-clipboard t);支持emacs和外部程序的粘贴
;;-----kill ring 长度
(setq kill-ring-max 200)

(require 'linum)
(global-linum-mode 1)
;;--------------------------快捷键定义------------------------
(global-set-key [(f12)] 'loop-alpha)  ;;玻璃
;;定义查找快捷键
(global-set-key [f5] 'replace-regexp) ;;支持正则表达式
(global-set-key [f6] 'replace-string)
(global-set-key [f8] 'flymake-goto-prev-error)
(global-set-key [f9] 'flymake-goto-next-error)
;;-------------------------------全选---------------------


(defun select-all ()
  "Select the whole buffer."
  (interactive)
  (goto-char (point-min))
  ;; Mark current position and push it into the mark ring.
  (push-mark-command nil nil)
  (goto-char (point-max))
  (message "ok."))

(provide 'select-all)

(autoload 'select-all "select-all"
  "Select the whole buffer." t nil)

;; user defined keys

(global-set-key "\C-x\C-a" 'select-all)

;;-------------------glass style------------------


(setq alpha-list '((85 55) (100 100)))

(defun loop-alpha ()
  (interactive)
  (let ((h (car alpha-list)))
    ((lambda (a ab)
       (set-frame-parameter (selected-frame) 'alpha (list a ab))
       (add-to-list 'default-frame-alist (cons 'alpha (list a ab)))
       ) (car h) (car (cdr h)))
    (setq alpha-list (cdr (append alpha-list (list h))))
    ))

;;==========================
(setq erlang-compile-extra-opts
      (list '(i . "include")
            'export_all
            (cons 'i "include")
            (cons 'i "deps/p1_xml/include")
            (cons 'i "deps/im_libs/apps/msync_proto/include")
            (cons 'i "deps/im_libs/apps/message_store/include")
            (cons 'i "../include")
            (cons 'i "../deps/p1_xml/include")
            (cons 'i "../deps/im_libs/apps/msync_proto/include")
            (cons 'i "../deps/im_libs/apps/message_store/include")
            (cons 'd (intern "'LAGER'"))
            (cons 'd (intern "'LICENSE'"))
            (list 'd (intern "'INITIAL_LICENSE_TIME'") 86400)
            'debug_info))

;;  this is set properly in the detection period
;; (setq erlang-root-dir  "/home2/chunywan/d/local/lib/erlang")

;; TODO: this is no good way to detect distel is installed.
(let ((distel-root (expand-file-name "~/.emacs.d/distel")))
  (when (file-exists-p distel-root)
    (let ((dist-el (expand-file-name "elisp" distel-root)))
      (add-to-list 'load-path dist-el)
      (message "distel setup")
      (require 'distel)
      (distel-setup)
      (defconst distel-shell-keys
        '(("M-i" erl-complete)
          ("M-?" erl-complete)
          ("M-." erl-find-source-under-point)
          ("M-," erl-find-source-unwind)
          ("M-*" erl-find-source-unwind)
          )
        "Additional keys to bind when in Erlang shell.")
      (defun erlang-shell-mode-hook-1 ()
        ;; add some Distel bindings to the Erlang shell
        (define-key erlang-mode-map (kbd "<f7>") #'erlang-compile)
        (dolist (spec distel-shell-keys)
          (define-key erlang-shell-mode-map (read-kbd-macro (car spec)) (cadr spec))))
      (add-hook 'erlang-shell-mode-hook 'erlang-shell-mode-hook-1))))

(defun my-erlang-compile ()
  (if erl-nodename-cache
      (setq inferior-erlang-machine-options
            (list "-sname"
                  (format "%s_remsh" (emacs-pid))
                  "-remsh"
                  (format "%s" erl-nodename-cache)
                  "-hidden"))
    (setq inferior-erlang-machine-options
          (list "-sname"
                (format "%s" (emacs-pid))
                "-pa"
                "../deps/lager/ebin"
                "-pa"
                "deps/lager/ebin"
                "-pa"
                "../../../../../deps/lager/ebin"
                "-pa"
                "../deps/im_libs/apps/msync_proto/ebin"
                "-pa"
                "deps/im_libs/apps/msync_proto/ebin"
                "-hidden"))
    )
  (erlang-compile))

(setq flycheck-erlang-include-path
      (list
       "../deps/p1_xml/include"
       "../include"
       "../deps/im_libs/apps/msync_proto/include"
       "../deps/im_libs/apps/message_store/include"))

(setq flycheck-erlang-library-path
      (list
       "../deps/lager/ebin"
       "../deps/p1_fsm/ebin"
       "../../../../lager/ebin"
       "../deps/im_libs/apps/msync_proto/ebin"
       ))

(add-hook 'erlang-mode-hook 'my-erlang-hook)
(defun my-erlang-hook ()
  (message "my erlang hook")
  (add-hook 'after-save-hook 'my-erlang-compile-on-save)
  )

(defun my-erlang-compile-on-save ()
  (if (and buffer-file-name
           (string-match "\\.erl$" buffer-file-name))
      (my-erlang-compile)))

(require 'company)
(require 'company-distel)
(add-to-list 'company-backends 'company-distel)


(message "init local finish")
(provide 'init-local)
