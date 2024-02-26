{ pkgs, lib, ... }: {
  home.file.".git_allowed_signers".text
    = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICB2o2d+XdoTIeUP115mn87lYWlOy+DEOSLqN0ET7AW3 khionu";
  home.shellAliases = {    
    vim = "nvim";
    nos = "sudo -E nvim /etc/nixos/configuration.nix";
    ls = "eza";
    yolo = "sudo nixos-rebuild switch";
    toclip = "xclip -selection \"clipboard\"";
  };
  programs.nushell.shellAliases = home.shellAliases
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
      user.signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICB2o2d+XdoTIeUP115mn87lYWlOy+DEOSLqN0ET7AW3 khionu";
      commit.gpgsign = true;
      gpg.format = "ssh";
      gpg.ssh.program = "${pkgs._1password-gui}/share/1password/op-ssh-sign";
      gig.ssh.allowedSignersFile = home.files.".git_allowed_signers".target;
      safe.directory = "/etc/nixos";
    };
    delta.enable = true;
  };
  programs.jujutsu.enable = true;
  programs.jujutsu.settings = {
    user.name = "Khionu Sybiern";
    user.email = "dev@khionu.net";
    ui.editor = "nvim";
  };
  programs.ssh.extraConfig = ''
  Host *
    IdentityAgent ~/.1password/agent.sock
  '';
  home.packages = with pkgs; [
    agenix.packages.x86_64-linux.agenix
    atool
    firefox
    rustup
    openfpgaloader
    tdesktop  
    spotify
    vivaldi
    heroic
    yubioath-flutter
    yubikey-personalization
    yubikey-manager-qt
    yubikey-touch-detector
    lazygit
    wireshark
    du-dust
    neofetch
    psmisc
    bat
    ripgrep
    eza
    xplr
    zq
    jq
    gcc
    curl
    wget
    zellij
    kitty
    discord-canary
    _1password
    zoom-us
    unzip
    zip
    htop
    xclip
    tailscale
    whois
  ];

  home.stateVersion = "23.11";
};
