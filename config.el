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

(setq doom-font (font-spec :family "Aporetic Sans Mono"
                           :size 15)
      doom-variable-pitch-font (font-spec :family "Inter"
                                          :size 17))

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
  (setq org-appear-autolinks nil
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
;; Light/dark follows ~/.config/theme/current, which theme-apply (see
;; ~/nixos/home/evie.nix) flips and then calls `evie/sync-theme' on the
;; running daemon.
(defun evie/system-theme ()
  (if (equal (file-symlink-p "~/.config/theme/current") "light") 'ef-day 'ef-autumn))
(defun evie/sync-theme ()
  (interactive)
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme (setq doom-theme (evie/system-theme)) t))
(setq doom-theme (evie/system-theme))
(setq modus-themes-to-toggle '(ef-autumn ef-day))
(map! "<f5>" #'ef-themes-toggle)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; modeline
(after! doom-modeline
  (setq display-time-format "%H:%M"
        display-time-default-load-average nil)
  (display-time-mode 1))

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

;; Digital declutter (2026-11-09 to 2026-12-08). Remove once it's over.
(defun evie/open-declutter ()
  (interactive)
  (find-file "~/org/declutter.org"))

(map! :leader
      :desc "Declutter rules" "o D" #'evie/open-declutter)

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

;; change eglot default inlay behavior to be off but add a map for
;; momentary inlay hints
(after! eglot
  (add-hook 'eglot-managed-mode-hook #'eglot-inlay-hints-mode-disable-h)
  (add-hook 'eglot-managed-mode-hook #'evil-normalize-keymaps)
  (map! :map eglot-mode-map
        :nv "g h" #'eglot-momentary-inlay-hints))

(defun eglot-inlay-hints-mode-disable-h ()
  (eglot-inlay-hints-mode -1))

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

;; `+tree-sitter' remaps c/c++ buffers to `c-ts-mode', which has its own
;; indent-offset var separate from cc-mode's `c-basic-offset' (which Doom
;; already sets). Fall back to 4 (matching our .clang-format files) when
;; there's nothing for dtrt-indent to guess from, e.g. a brand-new file.
(setq-default c-ts-mode-indent-offset 4)

;; Doom's dtrt-indent (`+guess') skips any buffer inside a project by
;; default, deferring to editorconfig/.dir-locals instead -- but we don't use
;; those, so nothing was guessing project C files' indentation and they fell
;; back to c-ts-mode's raw default of 2. Let it guess in projects too.
(setq +whitespace-guess-in-projects t)

;; python stuff
;; Use ruff instead of black when formatting Python with SPC c f
(after! apheleia
  (setf (alist-get 'python-mode apheleia-mode-alist) '(ruff-isort ruff)
        (alist-get 'python-ts-mode apheleia-mode-alist) '(ruff-isort ruff)))

(setq lsp-pyright-langserver-command "basedpyright"
      lsp-pyright-type-checking-mode "standard")

;; Only if you installed basedpyright instead of pyright:
;; (setq lsp-pyright-langserver-command "basedpyright")

;; java (school labs: maven + junit projects)
;; :tools (lsp +eglot) is our global LSP backend, and doom's java module
;; doesn't drive eglot itself, so eglot-java is what actually launches
;; eclipse.jdt.ls (it bootstraps its own jdtls install on first use).
(use-package! eglot-java
  :hook ((java-mode . eglot-java-mode)
         (java-ts-mode . eglot-java-mode)))

;; LEETCODE
(use-package! leetcode
  :commands (leetcode leetcode-show-problem-by-slug +leetcode-goto)
  :config
  (setq leetcode-prefer-language "python3"
        leetcode-save-solutions t
        leetcode-directory "~/school/leetcode")

  ;; upstream bug: the PENDING branch wraps its body in an extra pair of
  ;; parens, so the first poll signals invalid-function (swallowed by aio)
  ;; and try/submit hang on "check submission" forever
  (aio-defun leetcode--api-check-submission (interpret-id problem on-success)
             (message "LeetCode check submission: %s" (format leetcode--url-check-submission interpret-id))
             (let* ((title-slug (leetcode-problem-title-slug problem))
                    (problem-id (leetcode-problem-id problem))
                    (url-request-method "GET")
                    (url-request-extra-headers `(,@(aio-await (leetcode--common-extra-headers))
                                                 ,(leetcode--referer (format leetcode--url-problems title-slug))))
                    (response (aio-await (aio-url-retrieve (format leetcode--url-check-submission interpret-id))))
                    (response-status (car response))
                    (response-buffer (cdr response)))
               (if-let ((error-info (plist-get response-status :error)))
                   (progn
                     (switch-to-buffer response-buffer)
                     (leetcode--warn "LeetCode check submission ERROR: %S" error-info))
                 (let ((result (leetcode--parse-buffer response-buffer)))
                   (let-alist result
                     (pcase .state
                       ((or "PENDING" "STARTED")
                        (aio-await (aio-sleep 0.5))
                        (aio-await (leetcode--api-check-submission interpret-id problem on-success)))
                       ("SUCCESS" (funcall on-success problem-id result))))))))

  ;; upstream refresh restores point to the :load-more row, which is still the
  ;; last line, so the new problems load above point and it looks like nothing
  ;; happened. jump to the first newly loaded problem instead
  (defun +leetcode-load-more ()
    (interactive)
    (let ((old (length (leetcode--filter (leetcode--problems-rows)))))
      (aio-wait-for (leetcode--load-more))
      (with-current-buffer leetcode--buffer-name
        (goto-char (point-min))
        (forward-line old)
        (recenter 0)
        (message "LeetCode: %d problems loaded" (leetcode-problems-num leetcode--problems)))))
  (define-key leetcode--load-more-map (kbd "RET") #'+leetcode-load-more)
  (define-key leetcode--load-more-map [mouse-1] #'+leetcode-load-more)

  ;; jump to any problem by number. upstream only looks in the loaded pages
  ;; (100 at a time), so 2406 meant 24 clicks on [Load More]. on a miss we
  ;; ask the api for that one problem and add it to the list. this also
  ;; fixes O / V / C / B and leetcode-daily for problems that aren't loaded
  (defun +leetcode--parse-question (q)
    (let-alist q
      (make-leetcode-problem
       :status .status :id .questionFrontendId :title .title :title-slug .titleSlug
       :acceptance (format "%.1f%%" (* .acRate 100)) :difficulty .difficulty
       :paid-only (eq .paidOnly t)
       :tags (mapcar (lambda (tg) (alist-get 'slug tg)) .topicTags))))

  (aio-defun +leetcode--search (keyword skip limit)
    "Fetch a page of questions without touching `leetcode--problems'."
    (let* ((url-request-method "POST")
           (url-request-extra-headers `(,leetcode--User-Agent ,leetcode--Content-Type))
           (url-request-data
            (leetcode--graphql-payload
             "problemsetQuestionListV2" leetcode--graphql-problemset-question-list-v2
             `(("categorySlug" . "all-code-essentials") ("skip" . ,skip) ("limit" . ,limit)
               ("filters" . ((filterCombineType . "ALL"))) ("searchKeyword" . ,keyword)
               ("sortBy" . ((sortField . "CUSTOM") (sortOrder . "ASCENDING"))))))
           (response (aio-await (aio-url-retrieve leetcode--url-graphql)))
           (buf (cdr response)))
      (unless (plist-get (car response) :error)
        (with-current-buffer buf
          (goto-char url-http-end-of-headers)
          (let-alist (json-read)
            (mapcar #'+leetcode--parse-question .data.problemsetQuestionListV2.questions))))))

  ;; no `setf' on the struct accessor here: doom eager-macroexpands this file
  ;; before leetcode.el loads, so setf doesn't know the accessor yet and
  ;; expands to a call to the nonexistent function `(setf
  ;; leetcode-problems-problems)'. aio swallows that error, so the fetch just
  ;; looks hung. set the slot with plain functions that resolve at runtime
  (defun +leetcode--set-problems (ps)
    (aset leetcode--problems (cl-struct-slot-offset 'leetcode-problems 'problems) ps))

  ;; this has to stay async. the callers are aio coroutines that usually
  ;; resume inside a url.el callback (e.g. right after the login request),
  ;; and blocking there with `aio-wait-for' deadlocks: url.el reuses the
  ;; keep-alive connection whose filter is still on the stack, so the
  ;; nested request never gets its response ("Contacting host" forever)
  (aio-defun +leetcode--ensure-problem (id)
    "Make sure problem ID is in `leetcode--problems', fetching it if needed."
    (let ((id (format "%s" id))
          (match (lambda (id ps) (seq-find (lambda (p) (equal (leetcode-problem-id p) id)) ps))))
      (or (funcall match id (leetcode-problems-problems leetcode--problems))
          (when (string-match-p "\\`[0-9]+\\'" id)
            (message "LeetCode: fetching problem %s..." id)
            (when-let* ((p (or (funcall match id (aio-await (+leetcode--search id 0 20)))
                               (funcall match id (aio-await
                                                  (+leetcode--search
                                                   "" (max 0 (- (string-to-number id) 50)) 100))))))
              ;; append without bumping :num so load-more pagination stays intact
              (+leetcode--set-problems
               (append (leetcode-problems-problems leetcode--problems) (list p)))
              p))
          (user-error "LeetCode: no problem #%s" id))))

  ;; prefetch before the upstream commands look the problem up. the aio
  ;; ones get an async wrapper; the browser one is a plain command run from
  ;; the command loop, where blocking is safe
  (aio-defun +leetcode--ensure-problem-a (fn id &rest args)
    (aio-await (+leetcode--ensure-problem id))
    (aio-await (apply fn (format "%s" id) args)))
  (advice-add #'leetcode-show-problem :around #'+leetcode--ensure-problem-a)
  (advice-add #'leetcode-solve-problem :around #'+leetcode--ensure-problem-a)

  (defadvice! +leetcode--ensure-problem-sync-a (id)
    :before #'leetcode-show-problem-in-browser
    (aio-wait-for (+leetcode--ensure-problem id)))

  ;; upstream rebuilds the slug from the title, which breaks on titles like
  ;; 2034's "Stock Price Fluctuation " (trailing space -> "...-fluctuation-").
  ;; the code-buffer lookup then gets nil and solve dies right after splitting
  ;; the windows, leaving the description in all four. use the real slug
  (defadvice! +leetcode--real-slug-a (fn title)
    :around #'leetcode--slugify-title
    (or (when-let* ((ps (and (boundp 'leetcode--problems) leetcode--problems
                             (leetcode-problems-problems leetcode--problems)))
                    (p (seq-find (lambda (p) (equal (leetcode-problem-title p) title)) ps)))
          (leetcode-problem-title-slug p))
        (replace-regexp-in-string "\\`-+\\|-+\\'" "" (funcall fn (string-trim title)))))

  ;; some callers pass a number from read-number, upstream compares with equal
  (defadvice! +leetcode--get-problem-by-id-string-a (fn id)
    :around #'leetcode--get-problem-by-id
    (funcall fn (format "%s" id)))

  ;; works from anywhere, no need to open the problem list first
  ;; the docstring is load-bearing: without one aio-defun buries
  ;; (interactive) in the body and the function isn't a command
  (aio-defun +leetcode-goto (id)
    "Open LeetCode problem number ID, fetching it if it isn't loaded."
    (interactive (list (read-string "LeetCode problem #: ")))
    (aio-await (leetcode--ensure-login))
    (aio-await (leetcode-show-problem id)))

  ;; a problem fetched above will come back again once load-more reaches it
  (defun +leetcode--dedupe ()
    (+leetcode--set-problems
          (cl-remove-duplicates (leetcode-problems-problems leetcode--problems)
                                :key #'leetcode-problem-id :test #'equal :from-end t)))
  (advice-add #'leetcode-refresh :before #'+leetcode--dedupe)

  ;; better result buffers. upstream try gives one PASS/FAIL for the whole run
  ;; and dumps all outputs then all expecteds with no inputs, submit crashes
  ;; on nil percentiles, and unknown status codes show nothing
  (defun +leetcode--fmt-num (fmt x) (if (numberp x) (format fmt x) "?"))

  (defun +leetcode--heading (ok text)
    (insert (propertize text 'face `(:inherit ,(if ok 'leetcode-accepted-face 'leetcode-error-face)
                                     :weight bold :height 1.3))
            "\n\n"))

  (defun +leetcode--field (label value)
    (when (and value (not (equal value "")))
      (insert (propertize label 'face 'font-lock-comment-face) "\n"
              (string-trim-right (format "%s" value)) "\n\n")))

  (defun +leetcode--add-testcase-button (problem-id input)
    (when (and input (not (string-empty-p input)))
      (insert-text-button "[Add to testcases]"
                          'action (lambda (_)
                                    (with-current-buffer (leetcode--testcase-buffer-name problem-id)
                                      (goto-char (point-max))
                                      (unless (bolp) (insert "\n"))
                                      (insert (string-trim input) "\n"))
                                    (message "LeetCode: added failing case to testcases"))
                          'follow-link t)
      (insert "\n\n")))

  (defun +leetcode--result-buffer (problem-id)
    (let ((buf (get-buffer-create (leetcode--result-buffer-name problem-id))))
      (with-current-buffer buf
        (let ((inhibit-read-only t)) (erase-buffer))
        (setq-local truncate-lines nil)
        (visual-line-mode +1))
      buf))

  (defun leetcode--show-testcases-result (problem-id result)
    (let-alist result
      (with-current-buffer (+leetcode--result-buffer problem-id)
        (pcase .status_code
          (10
           (let* ((n (or .total_testcases (length .expected_code_answer)))
                  (lines (split-string (string-trim-right
                                        (leetcode--testcase-buffer-data problem-id))
                                       "\n"))
                  (per (and (> n 0) (zerop (% (length lines) n)) (/ (length lines) n)))
                  (bits (and (stringp .compare_result) (= (length .compare_result) n)
                             .compare_result))
                  (passed 0))
             (dotimes (i n)
               (when (if bits (eq (aref bits i) ?1)
                       (equal (elt .code_answer i) (elt .expected_code_answer i)))
                 (cl-incf passed)))
             (+leetcode--heading (= passed n) (format "%s  %d/%d passed"
                                                     (if (= passed n) "✓ PASS" "✗ FAIL")
                                                     passed n))
             (+leetcode--field "Runtime" .status_runtime)
             (dotimes (i n)
               (let* ((out (elt .code_answer i))
                      (exp (elt .expected_code_answer i))
                      (ok (if bits (eq (aref bits i) ?1) (equal out exp))))
                 (insert (propertize (format "%s Case %d" (if ok "✓" "✗") (1+ i))
                                     'face `(:inherit ,(if ok 'leetcode-accepted-face 'leetcode-error-face)
                                             :weight bold))
                         "\n")
                 (when per
                   (insert (propertize "  input     " 'face 'font-lock-comment-face)
                           (string-join (seq-subseq lines (* i per) (* (1+ i) per)) "\n            ")
                           "\n"))
                 (insert (propertize "  output    " 'face 'font-lock-comment-face) (format "%s" out) "\n")
                 (unless ok
                   (insert (propertize "  expected  " 'face 'font-lock-comment-face)
                           (propertize (format "%s" exp) 'face 'leetcode-accepted-face) "\n"))
                 (let ((so (elt .std_output_list i)))
                   (when (and so (not (string-empty-p so)))
                     (insert (propertize "  stdout\n" 'face 'font-lock-comment-face)
                             (replace-regexp-in-string "^" "    " (string-trim-right so)) "\n")))
                 (insert "\n")))
             (message "LeetCode try: %d/%d passed" passed n)))
          ((or 12 13 14)
           (+leetcode--heading nil .status_msg)
           (+leetcode--field "Last test case" .last_testcase)
           (+leetcode--field "Expected" .expected_output)
           (+leetcode--field "Stdout" .std_output)
           (message "LeetCode try: %s" .status_msg))
          (15
           (+leetcode--heading nil .status_msg)
           (+leetcode--field "Error" .full_runtime_error)
           (+leetcode--field "Last test case" .last_testcase)
           (+leetcode--field "Stdout" (and (sequencep .std_output_list)
                                           (string-join (append .std_output_list nil) "")))
           (message "LeetCode try: %s" .status_msg))
          (20
           (+leetcode--heading nil .status_msg)
           (+leetcode--field "Error" .full_compile_error)
           (message "LeetCode try: %s" .status_msg))
          (_
           (+leetcode--heading nil (format "%s (status %s)" .status_msg .status_code))
           (insert (pp-to-string result))))
        (goto-char (point-min)))))

  (defun leetcode--show-submission-result (problem-id result)
    (let-alist result
      (with-current-buffer (+leetcode--result-buffer problem-id)
        (let ((progress (format "%s/%s testcases" .total_correct .total_testcases)))
          (pcase .status_code
            (10
             (+leetcode--heading t (format "✓ %s  %s" .status_msg progress))
             (insert (format "Runtime  %-10s beats %s%%\n"
                             .status_runtime (+leetcode--fmt-num "%.1f" .runtime_percentile))
                     (format "Memory   %-10s beats %s%%\n\n"
                             .status_memory (+leetcode--fmt-num "%.1f" .memory_percentile)))
             (message "LeetCode: ✓ Accepted  %s (beats %s%%)  %s (beats %s%%)"
                      .status_runtime (+leetcode--fmt-num "%.0f" .runtime_percentile)
                      .status_memory (+leetcode--fmt-num "%.0f" .memory_percentile)))
            (11
             (+leetcode--heading nil (format "✗ %s  %s" .status_msg progress))
             (let ((input (or .last_testcase .input)))
               (+leetcode--field "Input" input)
               (+leetcode--field "Output" .code_output)
               (insert (propertize "Expected" 'face 'font-lock-comment-face) "\n"
                       (propertize (format "%s" .expected_output) 'face 'leetcode-accepted-face)
                       "\n\n")
               (+leetcode--field "Stdout" .std_output)
               (+leetcode--add-testcase-button problem-id input))
             (message "LeetCode: ✗ Wrong Answer (%s)" progress))
            ((or 12 13 14 15)
             (+leetcode--heading nil (format "✗ %s  %s" .status_msg progress))
             (+leetcode--field "Error" .full_runtime_error)
             (+leetcode--field "Last test case" .last_testcase)
             (+leetcode--field "Expected" .expected_output)
             (+leetcode--field "Stdout" .std_output)
             (+leetcode--add-testcase-button problem-id .last_testcase)
             (message "LeetCode: ✗ %s (%s)" .status_msg progress))
            (20
             (+leetcode--heading nil (format "✗ %s" .status_msg))
             (+leetcode--field "Error" .full_compile_error)
             (message "LeetCode: ✗ %s" .status_msg))
            (_
             (+leetcode--heading nil (format "%s (status %s)" .status_msg .status_code))
             (insert (pp-to-string result)))))
        (goto-char (point-min))
        (display-buffer (current-buffer)
                        '((display-buffer-reuse-window leetcode--display-result)
                          (reusable-frames . visible))))))

  ;; evil style bindings under localleader (spc m)
  (map! :map leetcode-solution-mode-map
        :localleader
        "t" #'leetcode-try
        "s" #'leetcode-submit
        "r" #'leetcode-restore-layout))

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

;;; ghostel: make it behave like a normal terminal
;; In evil insert/normal state these keys go straight to the shell instead of
;; being eaten by Emacs/evil. The ghostel commands that lived under C-c move to
;; the localleader (SPC m) in normal state. Emacs state is untouched, so `C-c C-c'
;; etc. still work there.
(after! evil-ghostel
  (defun +evie/ghostel-clear (&optional scrollback)
    "Clear like a normal terminal: push the screen into scrollback and
redraw the prompt at the top of the window. With prefix arg, also wipe
the scrollback (like `clear -x' vs `clear')."
    (interactive "P")
    (if scrollback (ghostel-clear-scrollback) (ghostel-clear))
    ;; normal state lets the window roam into scrollback; insert follows the
    ;; live cursor, so the cleared screen is what you see
    (unless (evil-insert-state-p) (evil-insert-state)))

  (defun +evie/ghostel-send-C-c ()
    "Send ^C to the shell (and drop back to insert state)."
    (interactive)
    (ghostel-send-key "c" "ctrl")
    (unless (evil-insert-state-p) (evil-insert-state)))

  (map! :map evil-ghostel-mode-map
        :ni "C-l" #'+evie/ghostel-clear
        :ni "C-c" #'+evie/ghostel-send-C-c
        ;; job control (evil would otherwise toggle emacs state)
        :i  "C-z" (cmd! (ghostel-send-key "z" "ctrl"))
        :localleader
        "l" #'ghostel-line-mode
        "c" #'ghostel-copy-mode
        "y" #'ghostel-copy-all
        "k" #'ghostel-clear-scrollback
        "q" #'ghostel-send-next-key
        "d" #'ghostel-char-mode
        "e" #'evil-ghostel-toggle-send-escape
        "n" #'ghostel-next-prompt
        "p" #'ghostel-previous-prompt))

;; ghostel's pixel anchor bottom-aligns the grid, so when the window height
;; isn't an exact multiple of the line height the leftover pixels at the top
;; show a sliver of scrollback (e.g. the previous `$' after C-l). Returning nil
;; here makes `ghostel--anchor-window' fall back to whole-line anchoring: the
;; first grid row sits at the window top and the spare pixels go below the last
;; row, like a real terminal.
(after! ghostel
  (defadvice! +evie/ghostel-no-scrollback-peek-a (&rest _)
    :override #'ghostel--balance-top-pad
    (ghostel--top-pad-set 0)
    nil))
