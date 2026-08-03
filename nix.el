;;; nix.el -*- lexical-binding: t; -*-

;; config file for nixos specific emacs customization

(defun evie/rebuild ()
  (interactive)
  (compile "sudo nixos-rebuild switch"))

(map! :leader
      :desc "Rebuild NixOS" "o r" #'evie/rebuild)
