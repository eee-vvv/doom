;;; y86-mode.el -*- lexical-binding: t; -*-

;; Minimal major mode for Y86-64 assembly (.ys) files, as used by the
;; CS:APP / CIS 3217 `sim' toolchain (yas/yis/ssim/psim).

(defvar y86-mode-opcodes
  '("halt" "nop" "rrmovq" "cmovle" "cmovl" "cmove" "cmovne" "cmovge" "cmovg"
    "irmovq" "rmmovq" "mrmovq"
    "addq" "subq" "andq" "xorq" "iaddq"
    "jmp" "jle" "jl" "je" "jne" "jge" "jg"
    "call" "ret" "pushq" "popq")
  "Y86-64 instruction mnemonics.")

(defvar y86-mode-directives
  '(".pos" ".align" ".quad" ".long" ".word" ".byte")
  "Y86-64 assembler (yas) directives.")

(defvar y86-mode-registers
  '("%rax" "%rcx" "%rdx" "%rbx" "%rsp" "%rbp" "%rsi" "%rdi"
    "%r8" "%r9" "%r10" "%r11" "%r12" "%r13" "%r14" "%r15")
  "Y86-64 register names.")

(defvar y86-mode-font-lock-keywords
  `((,(regexp-opt y86-mode-opcodes 'words) . font-lock-keyword-face)
    (,(regexp-opt y86-mode-directives 'words) . font-lock-preprocessor-face)
    (,(regexp-opt y86-mode-registers 'words) . font-lock-variable-name-face)
    ("^[ \t]*\\([A-Za-z_.][A-Za-z0-9_.]*\\):" 1 font-lock-function-name-face)
    ("\\$-?\\(0x[0-9a-fA-F]+\\|[0-9]+\\)" . font-lock-constant-face)
    ("\\_<0x[0-9a-fA-F]+\\_>" . font-lock-constant-face)))

(defvar y86-mode-syntax-table
  (let ((table (make-syntax-table)))
    (modify-syntax-entry ?# "<" table)
    (modify-syntax-entry ?\n ">" table)
    (modify-syntax-entry ?_ "_" table)
    (modify-syntax-entry ?. "_" table)
    (modify-syntax-entry ?% "_" table)
    table)
  "Syntax table for `y86-mode'.")

;;;###autoload
(define-derived-mode y86-mode prog-mode "Y86"
  "Major mode for editing Y86-64 assembly (.ys) files."
  :syntax-table y86-mode-syntax-table
  (setq-local comment-start "# ")
  (setq-local comment-end "")
  (setq-local font-lock-defaults '(y86-mode-font-lock-keywords nil t))
  (setq-local indent-tabs-mode t)
  (setq-local tab-width 8))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.ys\\'" . y86-mode))

;; --- Tooling: assemble/run against the built `sim/' toolchain -------------

(defconst y86-sim-root "~/school/computer-architecture-3217/y86/sim/"
  "Path to the y86 `sim/' directory (containing misc/yas).")

(defun y86--sim-root ()
  "Return `y86-sim-root', erroring if it hasn't been built yet."
  (let ((root (expand-file-name y86-sim-root)))
    (unless (file-exists-p (expand-file-name "misc/yas" root))
      (error "misc/yas not found in %s -- build it first with `make -C sim'" root))
    root))

(defun y86--tool (relpath)
  (expand-file-name relpath (y86--sim-root)))

(defun y86--run-tool (tool-path &optional flags)
  "Assemble the current .ys buffer, then run TOOL-PATH on the resulting .yo."
  (when (buffer-modified-p) (save-buffer))
  (let* ((file (buffer-file-name))
         (default-directory (file-name-directory file))
         (base (file-name-nondirectory (file-name-sans-extension file))))
    (compile (format "%s %s.ys && %s %s %s.yo"
                      (shell-quote-argument (y86--tool "misc/yas")) base
                      (shell-quote-argument tool-path) (or flags "") base))))

(defun y86-assemble ()
  "Assemble the current .ys file with yas."
  (interactive)
  (when (buffer-modified-p) (save-buffer))
  (let* ((file (buffer-file-name))
         (default-directory (file-name-directory file)))
    (compile (format "%s %s"
                      (shell-quote-argument (y86--tool "misc/yas"))
                      (shell-quote-argument (file-name-nondirectory file))))))

(defun y86-run-isa ()
  "Assemble + run the ISA simulator (yis) on the current file."
  (interactive)
  (y86--run-tool (y86--tool "misc/yis")))

(defun y86-run-seq ()
  "Assemble + run the SEQ processor simulator (GUI) on the current file."
  (interactive)
  (y86--run-tool (y86--tool "seq/ssim") "-g"))

(defun y86-run-seq-check ()
  "Assemble + run SEQ in TTY mode with an ISA-consistency check."
  (interactive)
  (y86--run-tool (y86--tool "seq/ssim") "-t"))

(defun y86-run-pipe ()
  "Assemble + run the PIPE processor simulator (GUI) on the current file."
  (interactive)
  (y86--run-tool (y86--tool "pipe/psim") "-g"))

(defun y86-run-pipe-check ()
  "Assemble + run PIPE in TTY mode with an ISA-consistency check."
  (interactive)
  (y86--run-tool (y86--tool "pipe/psim") "-t"))

(defun y86-build-sim ()
  "Rebuild the whole y86 sim/ toolchain."
  (interactive)
  (let ((default-directory (y86--sim-root)))
    (compile "make all")))

(add-hook 'y86-mode-hook
          (lambda ()
            (setq-local compile-command
                        (format "%s %s.ys && %s %s.yo"
                                (shell-quote-argument (y86--tool "misc/yas"))
                                (file-name-nondirectory (file-name-sans-extension (or (buffer-file-name) "a.ys")))
                                (shell-quote-argument (y86--tool "misc/yis"))
                                (file-name-nondirectory (file-name-sans-extension (or (buffer-file-name) "a.ys")))))))

(map! :map y86-mode-map
      :localleader
      "a" #'y86-assemble
      "i" #'y86-run-isa
      "s" #'y86-run-seq
      "S" #'y86-run-seq-check
      "p" #'y86-run-pipe
      "P" #'y86-run-pipe-check
      "b" #'y86-build-sim)

(provide 'y86-mode)
;;; y86-mode.el ends here
