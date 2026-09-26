;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Evie Anderson"
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

(setq doom-font (font-spec :family "Aporetic Sans Mono" :size 15)
      doom-variable-pitch-font (font-spec :family "Inter" :size 17))

(after! org
  (setq org-hide-emphasis-markers t
        org-pretty-entities t
        org-use-sub-superscripts '{}))

(custom-set-faces!
  '(org-document-title :height 1.8 :weight bold)
  '(org-level-1 :height 1.1 :weight bold)
  '(org-level-2 :height 1.05 :weight semi-bold))

(add-hook! 'org-mode-hook
  (display-line-numbers-mode -1)
  (visual-line-mode 1)
  (setq-local line-spacing 0.2)
  (mixed-pitch-mode 1)
  (olivetti-mode 1)
  (org-appear-mode 1))

(after! mixed-pitch
  (setq mixed-pitch-set-height t))

(after! olivetti
  (setq-default olivetti-body-width 90))

(after! org-appear
  (setq org-appear-autolinks t
        org-appear-autoentities t
        org-appear-autosubmarkers t))


;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'ef-bio)
(setq ef-themes-to-toggle '(ef-bio ef-light))
(map! "<f5>" #'ef-themes-toggle)

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
(setq org-agenda-skip-deadline-if-done t)

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

;; Capture a date and a list of exercise names to create a log entry template
;; in ~/org/lifting.org.
;; TODO: this can probably be so much fancier and maybe formatted in a way that
;; allows for more data analysis
(defvar evie/lifting-exercises
  '("Squat" "Dead Lift" "Bench Press" "Overhead Press" "Barbell Row" "Accessory")
  "Completion candidates for the lifting capture template.")

(defun evie/lifting-capture-template ()
  "Build a lifting log entry: date heading plus one subheading per lift."
  (let* ((time (org-read-date nil t))
         (date (format-time-string "%Y-%m-%d %a" time))
         (lifts (completing-read-multiple "Lifts (comma-separated): "
                                          evie/lifting-exercises)))
    (concat "** " date " - %?\n"
            (mapconcat (lambda (lift) (concat "*** " lift)) lifts "\n")
            "\n")))

(after! org-capture
  (add-to-list 'org-capture-templates
               '("l" "Lifting log" entry
                 (file+headline "~/org/lifting.org" "Logs")
                 (function evie/lifting-capture-template))))

;; eglot's on-type formatting (triggered via post-self-insert-hook on RET
;; and `}') races clangd's document sync and clangd rejects it with
;; "trying to format non-added document", which aborts the edit instead of
;; falling back to normal indentation. `newline' (evil insert-mode RET)
;; runs that hook; `evil-open-below' (`o') doesn't, which is why only RET
;; broke. Telling eglot the server lacks the capability restores normal
;; indentation on RET.
(after! eglot
  (add-to-list 'eglot-ignored-server-capabilities :documentOnTypeFormattingProvider))

;; clangd's on-type formatting was also what continued comments (adding
;; leading `* ' after RET inside a /** */ block, continuing `// '), so
;; disabling it above loses that along with the crash. `c-context-line-break'
;; does the same job natively (break the line, reindent, continue the
;; comment) without any LSP round-trip. `evil-ret' honors `newline' remaps
;; via `command-remapping', so this is what fires on RET in insert state.
(after! cc-mode
  (define-key c-mode-base-map [remap newline] #'c-context-line-break))

;; java (school labs: maven + junit projects)
;; :tools (lsp +eglot) is our global LSP backend, and doom's java module
;; doesn't drive eglot itself, so eglot-java is what actually launches
;; eclipse.jdt.ls (it bootstraps its own jdtls install on first use).
(use-package! eglot-java
  :hook ((java-mode . eglot-java-mode)
         (java-ts-mode . eglot-java-mode)))

;; imports
(load! "nix")
(load! "mail")
(load! "lisp/y86-mode")

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
