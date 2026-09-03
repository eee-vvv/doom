;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "evie anderson"
      user-mail-address "evie@evie-anderson.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;;kju - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they -------
;; accept. For example:
;;
(setq doom-font (font-spec :family "Fira Code" :size 16 :weight 'normal)
      doom-variable-pitch-font (font-spec :family "Fira Code" :size 16))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-gruvbox)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; modeline
(after! doom-modeline
  (setq display-time-format "%H:%M"
        display-time-default-load-average nil)
  (display-time-mode 1)
  (display-battery-mode 1))

;; dashboard stuff
(setq fancy-splash-image (concat doom-user-dir "emacs-gnu-logo.png"))

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")
(setq diary-file "~/org/diary")
(setq org-agenda-diary-file "~/org/diary")
(setq org-agenda-include-diary t)
(setq org-roam-directory "~/org/roam/")

(setq org-roam-dailies-capture-templates
      '(("d" "default" entry "* %<%I:%M %p> %?"
         :target (file+head "%<%Y-%m-%d>.org"
                            "#+title: %<%Y-%m-%d>\n"))))

;; (setq org-agenda-skip-scheduled-if-done t)
;; (setq org-agenda-skip-deadline-if-done t)

;; org-habit: consistency graphs in the agenda for tasks with a
;; SCHEDULED repeater and a :STYLE: habit property.
(after! org
  (require 'org-habit))

(after! org-habit
  (setq org-habit-preceding-days 30
        org-habit-following-days 2))

;; Type French accents in org files via ASCII sequences, e.g. e' -> é,
;; e` -> è, c, -> ç. Starts off; toggle with C-\ while in an org buffer.
(add-hook 'org-mode-hook
          (lambda () (setq input-method-title "FR")
            (setq-local default-input-method "french-postfix")))


;; Capture everything to todo.org's Inbox as a TODO item (not Doom's default
;; checkbox), so it participates in agenda TODO views/state cycling like the
;; rest of my org files. Refile (SPC m r) out anything that isn't a genuine
;; one-off todo during review.
(after! org
  (setq org-capture-templates
        (cons '("t" "Inbox" entry
                (file+headline +org-capture-todo-file "Inbox")
                "* TODO %?\n%i" :prepend t)
              (assoc-delete-all "t" org-capture-templates))))

;; imports
(load! "nix")

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
