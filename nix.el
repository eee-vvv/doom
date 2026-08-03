;;; nix.el -*- lexical-binding: t; -*-

;; config file for nixos specific emacs customization

(defun evie/rebuild ()
  (interactive)
  (compile "sudo nixos-rebuild switch"))

(defun evie/find-file-nixos-config ()
  (interactive)
  (find-file "~/nixos/"))

(map! :leader
      :desc "Find a file in NixOS config" "f n" #'evie/find-file-nixos-config)

(defun evie/pi-wg-status ()
  (interactive)
  (async-shell-command
   (format "sudo wg")))

(defun evie/pi-wg-up ()
  (interactive)
  (async-shell-command
   (format "sudo wg-quick up /home/evie/.config/wireguard/pi-t480.conf")))

(defun evie/pi-wg-down ()
  (interactive)
  (async-shell-command
   (format "sudo wg-quick down /home/evie/.config/wireguard/pi-t480.conf")))

(defun evie/big-wg-status ()
  (interactive)
  (let ((default-directory "/ssh:big:/home/evie/"))
    (async-shell-command "sudo wg")))

(defun evie/big-wg-up ()
  (interactive)
  (let ((default-directory "/ssh:big:/home/evie/"))
    (async-shell-command "sudo wg-quick up ny")))

(defun evie/big-wg-down ()
  (interactive)
  (let ((default-directory "/ssh:big:/home/evie/"))
    (async-shell-command
     "sudo wg-quick down ny && sudo systemctl start transmission-daemon")))

(map! :leader
      (:prefix ("z" . "System admin")
       :desc "Rebuild NixOS" "r" #'evie/rebuild
       (:prefix ("w" . "Wireguard tunnel")
        :desc "Status" "s" #'evie/pi-wg-status
        :desc "Turn on home tunnel" "u" #'evie/pi-wg-up
        :desc "Turn off home tunnel" "d" #'evie/pi-wg-down)
       (:prefix ("b" . "big (server)")
        :desc "Status" "s" #'evie/big-wg-status
        :desc "Turn on big vpn" "u" #'evie/big-wg-up
        :desc "Turn off big vpn" "d" #'evie/big-wg-down)))
