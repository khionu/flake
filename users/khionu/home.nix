{ pkgs, lib, ... }: let
  pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICB2o2d+XdoTIeUP115mn87lYWlOy+DEOSLqN0ET7AW3 khionu";
  global_envvars = { # Global as far as my user is concerned
    EDITOR = "nvim";
    # Enables using 1P for SSH PKI
    SSH_AUTH_SOCK = "/home/khionu/.1password/agent.sock";
  };
in {
  home.sessionVariables = global_envvars;
  programs.nushell.enable = true;
  programs.nushell.shellAliases = { 
    toclip = "xclip -selection \"clipboard\"";
    yolo = "sudo nixos-rebuild switch";
    # nos = "sudo -E nvim /etc/nixos/flake.nix";
  };# -- TODO: `nos` should be more than "edit 1 file"
  programs.nushell.environmentVariables = global_envvars;
  # -- Nushell has a neat little banner by default, partially to talk about itself and
  # -- partially to get you to check out the config options, which are numerous
  programs.nushell.extraConfig = ''
    $env.config.show_banner = false

    def flakepull [] {
      cd /etc/nixos
      sudo -E jj git fetch
      sudo -E jj new main
      cd -
    }
  '';
  # -- Automatically load my devShells on directory change
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  # -- Really really nice autocomplete for a large set of programs
  programs.carapace.enable = true;
  # -- We'll try disabling, see if this breaks anything
  # programs.bash.enable = true;
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;
  };
  # -- Keeping git around for some tools that expect it
  programs.git = {
    enable = true;
    userName = "Khionu Sybiern";
    userEmail = "dev@khionu.net";
    ignores = [
      ".direnv"
      ".jj"
      "node_modules"
      "target/debug"
      "target/release"
      "target/docs"
    ];
  #   extraConfig = {
  #     init = { defaultBranch = "main"; };
  #     push = { autoSetupRemote = true; };
  #     user.signingkey = pubkey;
  #     commit.gpgsign = true;
  #     gpg.format = "ssh";
  #     gpg.ssh.program = "${pkgs._1password-gui}/share/1password/op-ssh-sign";
  #     gpg.ssh.allowedSignersFile = "/home/khionu/.allowed_signers";
  #     safe.directory = "/etc/nixos";
  #   };
    delta.enable = true;
  };
  home.file.".allowed_signers".text = pubkey;
  programs.jujutsu.enable = true;
  programs.jujutsu.settings = {
    user.name = "Khionu Sybiern";
    user.email = "dev@khionu.net";
    ui.default-command = "log"; # normal default, to silence the tip
    ui.pager = "less -FR"; # default includes -X, which prevents cleanup
    git.push-branch-prefix = "push/khionu/";
    snapshot.max-new-file-size = "5MiB"; # PDFs
    signing.sign-all = "true";
    signing.backend = "ssh";
    signing.key = pubkey;
    # -- This allows using 1P to sign commits
    signing.backends.ssh.program = "${pkgs._1password-gui}/share/1password/op-ssh-sign";
    # -- For verification of signatures locally
    signing.backends.ssh.allowed-signers = "/home/khionu/.allowed_signers";
    # -- Slightly better snapshot times in general, much better for larger repos
    core.fsmonitor = "watchman";
  };
  # -- Can be redundant
  programs.ssh.extraConfig = ''
    Host *
      IdentityAgent ~/.1password/agent.sock
  '';
  programs.firefox.enable = true;
  programs.firefox.policies = {
    BlockAboutConfig = true; # -- We're only managing that here
    DisablePocket = true; # -- I don't want to use this ever
    EnableTrackingProtection = { # -- YASSSSSSSS
      Value = true;
      Cryptomining = true;
      Fingerprinting = true;
      EmailTracking = true;
    };
    OfferToSaveLogins = false; # -- I use 1P
    PasswordManagerEnabled = false; # -- ^
    PromptForDownloadLocation = true;
  };
  programs.bat.enable = true;
  programs.ripgrep.enable = true;
  programs.eza.enable = true;
  programs.eza.enableNushellIntegration = true;
  programs.eza.icons = true; # -- Depends on NerdFonts
  programs.eza.extraOptions = [ "--header" "--group-directories-first" ];
  programs.zellij.enable = true;
  programs.zellij.settings = {
    mirror_session = true;
  };
  programs.bottom.enable = true; # -- Better than htop by a lot
  programs.bottom.settings = {
    flags = {
      regex = true;
      # battery = false; TODO: make this infer from whether we're on a laptop or not
      mem_as_value = true; # -- Values as MB/GB
      tree = true; # -- For process list
      show_table_scroll_position = true;
      enable_gpu = true;
      enable_cache_memory = true;
    };
  };
  home.packages = with pkgs; [
    # Need to pass agenix through home-manager's extraSpecialArgs
    # agenix.packages.x86_64-linux.agenix
    rage
    atool
    vivaldi
    tdesktop
    spotify
    yubikey-personalization
    yubikey-manager-qt
    yubikey-touch-detector
    du-dust
    neofetch
    discord-canary
    zoom-us
    unzip
    zip
    xclip
    whois
    ventoy-full
    glow
    httpie
    vhs
    watchman
    imagemagick
    clang
  ];

  home.stateVersion = "23.11";
}

