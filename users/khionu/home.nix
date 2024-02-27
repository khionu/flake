systemConfig:
{ pkgs, lib, ... }: let
  shellAliases = { 
    vim = "nvim";
    # nos = "sudo -E nvim /etc/nixos/configuration.nix"; # TODO: Replace with flake-oriented commands
    ls = "eza";
    yolo = "sudo nixos-rebuild switch --flake ~/repos/flake#${systemConfig.networking.hostName}";
    toclip = "xclip -selection \"clipboard\"";
  };
  pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICB2o2d+XdoTIeUP115mn87lYWlOy+DEOSLqN0ET7AW3 khionu";
in {
  home.file.".git_allowed_signers".text = pubkey;
  home.shellAliases = shellAliases;
  programs.nushell.enable = true;
  programs.nushell.shellAliases = shellAliases;
  programs.nushell.environmentVariables = {
    SSH_AUTH_SOCK = "/home/khionu/.1password/agent.sock";
  };
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.carapace.enable = true;
  programs.bash.enable = true;
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;
  };
  programs.fzf.enable = true;
  programs.git = {
    enable = true;
    userName = "Khionu Sybiern";
    userEmail = "dev@khionu.net";
    ignores = [
      ".direnv"
    ];
    extraConfig = {
      init = { defaultBranch = "main"; };
      push = { autoSetupRemote = true; };
      user.signingkey = pubkey;
      commit.gpgsign = true;
      gpg.format = "ssh";
      gpg.ssh.program = "${pkgs._1password-gui}/share/1password/op-ssh-sign";
      gpg.ssh.allowedSignersFile = "~/.git_allowed_signers";
      safe.directory = "/etc/nixos";
    };
    delta.enable = true;
  };
  programs.jujutsu.enable = true;
  programs.jujutsu.settings = {
    user.name = "Khionu Sybiern";
    user.email = "dev@khionu.net";
    ui.editor = "nvim";
    ui.default-command = "log";
    ui.pager = "less -FRX";
    # signing.sign-all = "true";
    # signing.backend = "ssh";
    # signing.key = pubkey;
    # signing.backends.ssh.program = "${pkgs._1password-gui}/share/1password/op-ssh-sign";
  };
  programs.ssh.extraConfig = ''
  Host *
    IdentityAgent ~/.1password/agent.sock
  '';
  home.packages = with pkgs; [
    # Need to pass agenix through home-manager's extraSpecialArgs
    # agenix.packages.x86_64-linux.agenix
    rage
    atool
    firefox
    vivaldi
    tdesktop
    spotify
    yubikey-personalization
    yubikey-manager-qt
    yubikey-touch-detector
    lazygit
    du-dust
    neofetch
    bat
    ripgrep
    eza
    curl
    wget
    zellij
    discord-canary
    _1password
    zoom-us
    unzip
    zip
    htop
    xclip
    whois
    ventoy-full
  ];

  home.stateVersion = "23.11";
}

