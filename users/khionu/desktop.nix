{ pkgs, lib, config, ... }: {
  programs.jujutsu.settings.signing = {
    sign-all = "true";
    backend = "ssh";
    backends.ssh.program = "${pkgs._1password-gui}/share/1password/op-ssh-sign";
    # -- For verification of signatures locally
    backends.ssh.allowed-signers = "/home/khionu/.allowed_signers";
  };
  programs.ssh.extraConfig = ''
    Host *
      IdentityAgent ~/.1password/agent.sock
  '';
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry;
  };
  programs.firefox.enable = true;
  programs.firefox.policies = {
    BlockAboutConfig = true;     # -- We're only managing that here
    DisablePocket = true;        # -- I don't want to use this ever
    EnableTrackingProtection = { # -- YASSSSSSSS
      Value = true;
      Cryptomining = true;
      Fingerprinting = true;
      EmailTracking = true;
    };
    OfferToSaveLogins = false;      # -- I use 1P
    PasswordManagerEnabled = false; # -- ^
    PromptForDownloadLocation = true;
  };
  home.packages = with pkgs; [
    discord-canary
    zoom-us
    vivaldi
    tdesktop
    spotify
    yubikey-personalization
    yubikey-manager-qt
    yubikey-touch-detector
    signal-desktop
    slack
    libsForQt5.kleopatra
    virt-manager
    virt-viewer
    qFlipper
  ];
}
