# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, home-manager, agenix, neovim-nightly, ... }:

let dcustom = lib: {
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = [
          # cosmic-dock needs dash-to-dock
          "dash-to-dock@micxgx.gmail.com"
          #"cosmic-dock@system76.com"

          "native-window-placement@gnome-shell-extensions.gcampax.github.com"

          #"user-theme@gnome-shell-extensions.gcampax.github.com"
          #"workspace-indicator@gnome-shell-extensions.gcampax.github.com"
          "appindicatorsupport@rgcjonas.gmail.com"
          "pop-shell@system76.com"
          "cosmic-workspaces@system76.com"
          "pop-cosmic@system76.com"
        ];
      };
      "org/gnome/desktop/wm/keybindings" = {
        # hide window: disable <super>h
        minimize = [ "<super>comma" ];
        # switch to workspace left: disable <super>left
        switch-to-workspace-left = [];
        # switch to workspace right: disable <super>right
        switch-to-workspace-right = [];
        # maximize window: disable <super>up
        maximize = [];
        # restore window: disable <super>down
        unmaximize = [];
        # move to monitor up: disable <super><shift>up
        move-to-monitor-up = [];
        # move to monitor down: disable <super><shift>down
        move-to-monitor-down = [];
        # super + direction keys, move window left and right monitors, or up and down workspaces
        # move window one monitor to the left
        move-to-monitor-left = [];
        # move window one workspace down
        move-to-workspace-down = [];
        # move window one workspace up
        move-to-workspace-up = [];
        # move window one monitor to the right
        move-to-monitor-right = [];
        # super + ctrl + direction keys, change workspaces, move focus between monitors
        # move to workspace below
        switch-to-workspace-down = [ "<primary><super>down" "<primary><super>j" ];
        # move to workspace above
        switch-to-workspace-up = [ "<primary><super>up" "<primary><super>k" ];
        # toggle maximization state
        toggle-maximized = [ "<super>m" ];
        # close window
        close = [ "<super>q" "<alt>f4" ];
      };
      "org/gnome/shell/keybindings" = {
        open-application-menu = [];
        # toggle message tray: disable <super>m
        toggle-message-tray = [ "<super>v" ];
        # show the activities overview: disable <super>s
        toggle-overview = [];
      };
      "org/gnome/mutter/keybindings" = {
        # disable tiling to left / right of screen
        toggle-tiled-left = [];
        toggle-tiled-right = [];
      };
      "org/gnome/settings-daemon/plugins/media-keys" = {
        # lock screen
        screensaver = [ "<super>escape" ];
        # home folder
        home = [ "<super>f" ];
        # launch email client
        email = [ "<super>e" ];
        # launch web browser
        www = [ "<super>b" ];
        # launch terminal
        terminal = [ "<super>t" ];
        # rotate video lock
        rotate-video-lock-static = [];
      };
      "org/gnome/mutter" = {
        workspaces-only-on-primary = false;
        edge-tiling = false;
      };
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        enable-hot-corners = false;
        show-battery-percentage = true;
      };
      "org/gnome/tweaks" = {
        show-extensions-notice = false;
      };
      "org/gnome/shell/extensions/pop-shell" = {
        snap-to-grid = true;
        tile-by-default = true;
      };
      "org/gnome/settings-daemon/plugins/power" = {
        sleep-inactive-ac-type = "nothing";
        sleep-inactive-battery-timeout = 2700;
        idle-dim = false;
      };
      "org/gnome/desktop/session" = {
        idle-delay = lib.hm.gvariant.mkUint32 0;
      };
    };
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      home-manager.nixosModules.home-manager
      # <home-manager/nixos>
    ];

  nixpkgs.overlays = [
    (import ./overlays/pop-control-center.nix)
    (import ./overlays/pop-desktop-widget.nix)
    (import ./overlays/pop-launcher.nix)
    (import ./overlays/pop-shell-shortcuts.nix)
    (import ./overlays/cosmic-dock.nix)
    (import ./overlays/cosmic-workspaces.nix)
    (import ./overlays/pop-cosmic.nix)
    neovim-nightly.overlay
    (final: prev: { firmware-manager = prev.firmware-manager.overrideAttrs (o: {
      installPhase = (o.installPhase or "") + ''
        # fuck why lmao
        cd $out/lib
        ln -s libfirmware_manager.so libfirmwaremanager.so.0
      '';
    });})
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 25;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  hardware.enableAllFirmware = true;

  swapDevices = [ {
    device = "/swap";
    size = 16384;
  } ]; 

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  security.polkit.enable = true;
  services.pcscd.enable = true;

  networking.hostName = "khionu-carbon"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.firewall.checkReversePath = "loose";
  systemd.services.NetworkManager-wait-online.enable = false;

  time.timeZone = "US/Pacific";
  i18n.defaultLocale = "en_US.utf8";

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    layout = "us";
    xkbVariant = "";
  };

  services.printing.enable = true;

  fonts = {
    fontDir.enable = true;
    enableDefaultFonts = true;
    fontconfig = {
      defaultFonts.monospace = [ "Berkeley Mono Variable" ];
    };
  };

  xdg.mime.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
    };
  };
  services.blueman.enable = true;

  programs.dconf.enable = true;

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;

  home-manager.users.khionu = { pkgs, lib, ... }: {
    home.shellAliases = {    
      vim = "nvim";
      nos = "sudo -E nvim /etc/nixos/configuration.nix";
      ls = "exa";
      yolo = "sudo nixos-rebuild switch";
      toclip = "xclip -selection \"clipboard\"";
    };
    programs.bash.bashrcExtra = ''
    overedit() {
      sudo -E nvim /etc/nixos/overlays/"$1"
    }

    _complete_overedit() {
      cd /etc/nixos/overlays/
    }

    complete -o nospace -o filenames -o default -F _complete_overedit overedit
    '';
    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;
    programs.zsh.enable = true;
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
        user.signingkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICB2o2d+XdoTIeUP115mn87lYWlOy+DEOSLqN0ET7AW3";
        commit.gpgsign = true;
        gpg.format = "ssh";
        gpg.ssh.program = "${pkgs._1password-gui}/share/1password/op-ssh-sign";
        safe.directory = "/etc/nixos";
      };
      delta.enable = true;
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
      gtkwave
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
      exa
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

    home.stateVersion = "22.11";

    dconf.settings = dcustom lib;
  };

  users.users.khionu = {
    isNormalUser = true;
    description = "Khionu Sybiern";
    extraGroups = [ "networkmanager" "wheel" "audio" ];
  };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    gnomeExtensions.pop-shell
    gnome.gnome-tweaks
    gnome.gnome-characters
    pop-control-center
    pop-desktop-widget
    pop-launcher
    pop-shell-shortcuts
    pop-cosmic
    cosmic-dock
    cosmic-workspaces
  ];

  programs.gnome-terminal.enable = true;
  services.gnome.gnome-settings-daemon.enable = true;

  programs.mtr.enable = true;

  xdg.portal.enable = true;

  programs._1password.enable = true;
  programs._1password-gui.enable = true;
  programs._1password-gui.polkitPolicyOwners = [ "khionu" ];

  services.tailscale.enable = true;
  programs.steam.enable = true;

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
    settings.substituters = [
      "https://nix-community.cachix.org"
    ];
    settings.trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  system.stateVersion = "22.05";
}
