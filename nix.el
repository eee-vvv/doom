;;; nix.el -*- lexical-binding: t; -*-

;; config file for nixos specific emacs customization

(defun evie/rebuild ()
  (interactive)
  (compile "sudo nixos-rebuild switch"))

(map! :leader
      :desc "Rebuild NixOS" "o r" #'evie/rebuild)

(defun evie/browse-nixos-config ()
  (interactive)
  (doom-project-browse "~/nixos/"))

(map! :leader
      :desc "Browse NixOS config" "f n" #'evie/browse-nixos-config)
