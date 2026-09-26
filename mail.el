;;; mail.el -*- lexical-binding: t; -*-

;; Multi-account mu4e: gmail (personal), azaspire (google workspace),
;; temple (outlook/microsoft 365, oauth2), proton (via protonmail-bridge).
;; The mbsync/msmtp config and the protonmail-bridge service live in
;; ~/nixos/home/evie.nix; edit there, not by hand on any one machine.
;;
;; First-time setup on a machine, after `nixos-rebuild switch` has installed
;; mu/isync/protonmail-bridge:
;;
;;   mkdir -p ~/.mail/{gmail,azaspire,temple,proton}
;;   mbsync -a                    ; will prompt/fail on temple until you've
;;                                 ; run mutt_oauth2.py --authorize once (see
;;                                 ; ~/nixos/README or the mbsync PassCmd) and
;;                                 ; protonmail-bridge has been logged in
;;                                 ; (see the comment above the systemd
;;                                 ; service in home/evie.nix)
;;   mu init --maildir ~/.mail \
;;     --my-address evie.ev.anderson@gmail.com \
;;     --my-address ev.anderson@azaspire.com \
;;     --my-address tuu18698@temple.edu \
;;     --my-address evie@evie-anderson.com
;;   mu index

(after! mu4e
  (setq mu4e-maildir "~/.mail"
        mu4e-update-interval 300 ; poll every 5 min while mu4e is open
        mu4e-context-policy 'pick-first
        mu4e-compose-context-policy 'ask-if-none
        ;; The +mbsync flag defaults this to "mbsync --all", but temple is
        ;; blocked on Temple IT's end (their tenant rejects third-party
        ;; OAuth2 clients -- see the mutt_oauth2.py comment below). Leaving
        ;; it out of the periodic poll avoids a spurious error every 5 min;
        ;; `mbsync temple` still works standalone if that ever gets sorted.
        mu4e-get-mail-command "mbsync gmail azaspire proton")

  ;; azaspire.com is a Google Workspace domain (same infra as gmail.com under
  ;; the hood) but doesn't literally contain "gmail" in the address or
  ;; maildir, so the +gmail flag's integrations need this explicit opt-in.
  (setq +mu4e-gmail-accounts '(("ev.anderson@azaspire.com" . "azaspire")))

  ;; Route all outgoing mail through msmtp instead of Emacs's built-in
  ;; smtpmail: the temple/outlook account authenticates over XOAUTH2, which
  ;; smtpmail doesn't support, but msmtp does. Each account below overrides
  ;; `message-sendmail-extra-arguments' to select its own msmtp account (see
  ;; ~/.msmtprc).
  (setq sendmail-program (executable-find "msmtp")
        send-mail-function #'smtpmail-send-it
        message-sendmail-f-is-evil t
        message-sendmail-extra-arguments '("--read-envelope-from")
        message-send-mail-function #'message-send-mail-with-sendmail)

  ;; NOTE: the *-folder paths below are each provider's default English
  ;; folder names. If mu4e turns up empty Sent/Trash/Drafts after the first
  ;; `mbsync -a', check the real names with `mbsync -l <channel>' and fix
  ;; these to match.

  (set-email-account! "gmail"
    '((user-mail-address  . "evie.ev.anderson@gmail.com")
      (user-full-name     . "Evie Anderson")
      (mu4e-sent-folder   . "/gmail/[Gmail]/Sent Mail")
      (mu4e-drafts-folder . "/gmail/[Gmail]/Drafts")
      (mu4e-trash-folder  . "/gmail/[Gmail]/Trash")
      (mu4e-refile-folder . "/gmail/[Gmail]/All Mail")
      (smtpmail-smtp-user . "evie.ev.anderson@gmail.com")
      (message-sendmail-extra-arguments . ("-a" "gmail")))
    t)

  (set-email-account! "azaspire"
    '((user-mail-address  . "ev.anderson@azaspire.com")
      (user-full-name     . "Evie Anderson")
      (mu4e-sent-folder   . "/azaspire/[Gmail]/Sent Mail")
      (mu4e-drafts-folder . "/azaspire/[Gmail]/Drafts")
      (mu4e-trash-folder  . "/azaspire/[Gmail]/Trash")
      (mu4e-refile-folder . "/azaspire/[Gmail]/All Mail")
      (smtpmail-smtp-user . "ev.anderson@azaspire.com")
      (message-sendmail-extra-arguments . ("-a" "azaspire"))))

  (set-email-account! "temple"
    '((user-mail-address  . "tuu18698@temple.edu")
      (user-full-name     . "Evie Anderson")
      (mu4e-sent-folder   . "/temple/Sent Items")
      (mu4e-drafts-folder . "/temple/Drafts")
      (mu4e-trash-folder  . "/temple/Deleted Items")
      (mu4e-refile-folder . "/temple/Archive")
      (smtpmail-smtp-user . "tuu18698@temple.edu")
      (message-sendmail-extra-arguments . ("-a" "outlook"))))

  (set-email-account! "proton"
    '((user-mail-address  . "evie@evie-anderson.com")
      (user-full-name     . "Evie Anderson")
      (mu4e-sent-folder   . "/proton/Sent")
      (mu4e-drafts-folder . "/proton/Drafts")
      (mu4e-trash-folder  . "/proton/Trash")
      (mu4e-refile-folder . "/proton/Archive")
      (smtpmail-smtp-user . "evie@evie-anderson.com")
      (message-sendmail-extra-arguments . ("-a" "proton")))))
