{ pkgs, lib, config, ... }: let
  props = config.meta.properties;
  pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICB2o2d+XdoTIeUP115mn87lYWlOy+DEOSLqN0ET7AW3 khionu";
  # Enables using 1P for SSH PKI
  global_envvars.SSH_AUTH_SOCK = lib.optionals is_desktop "/home/khionu/.1password/agent.sock";
  has_prop = p: elem p props;
in {
  imports = [
    lib.optionals (elem "platform.desktop" props) ./desktop.nix
  ];
  home.sessionVariables = global_envvars;
  # home.activation.getDotfiles = lib.hm.dag.entryAfter ["writeBoundary"] ''
  #   run git clone $VERBOSE_ARG \
  #       https://github.com/khionu/dotfiles $HOME/.local/dotrepo
  # '';
  programs.nushell.enable = true;
  programs.nushell.shellAliases = { 
    toclip = "xclip -selection \"clipboard\"";
    # -- `sudo -E` is required for pulling from authenticated repositories, for now
    # -- TODO: make another key for root to use for git-only purposes
    yolo = "sudo -E nixos-rebuild switch";
    reboot-win = "systemctl reboot --boot-loader-entry=auto-windows";
    reboot-fm = "systemctl reboot --boot-loader-entry=auto-reboot-to-firmware-setup";
  };
  programs.nushell.environmentVariables = global_envvars;
  # -- Nushell has a neat little banner by default, partially to talk about itself and
  # -- partially to get you to check out the config options, which are numerous
  programs.nushell.extraConfig = ''
    $env.config.show_banner = false

    def flakepull [branch: string = "main"] {
      let br = $"($branch)@origin"
      cd /etc/nixos
      sudo -E jj git fetch
      sudo -E jj new $br
      cd -
    }

    def flakeedit [] {
      hx /etc/nixos
    }
  '';
  # -- Automatically load my devShells on directory change
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  # -- Really really nice autocomplete for a large set of programs
  programs.carapace.enable = true;
  # -- Keeping git around for some tools that expect it
  programs.helix = {
    enable = true;
    defaultEditor = true;
  };
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
  };
  home.file.".allowed_signers".text = pubkey;
  programs.jujutsu.enable = true;
  programs.jujutsu.settings = {
    user.name = "Khionu Sybiern";
    user.email = "dev@khionu.net";
    ui.default-command = "log"; # normal default, to silence the tip
    ui.pager = "less -FR"; # default includes -X, which prevents cleanup
    ui.log-synthetic-elided-nodes = true;
    ui.graph.style = "square";
    git.push-branch-prefix = "push/khionu/";
    snapshot.max-new-file-size = "5MiB"; # PDFs
    # Enable signing only if my keys (in 1P) are available
    # -- Slightly better snapshot times in general, much better for larger repos
    core.fsmonitor = "watchman";
    templates = {
       log_node = ''
         if(!self, label("elided node", "⇋"),
           if(current_working_copy, label("wcc node", "⚒"),
             if(root, "┴",
               if(immutable, label("immutable node", "◆"),
                 if(description.starts_with("wip: "), label("wip node", "!"),
                   "○"
                 )
               )
             )
           )
         )
       '';
       op_log_node = "if(current_operation, \"@\", \"◉\")";
    };
    colors = {
      "immutable node" = { fg = "bright cyan"; };
      "elided node" = { fg = "bright black"; };
      "wip node" = { fg = "yellow"; bold = true; };
      "wcc node" = { fg = "green"; bold = true; };
    };
    # -- Rebase all non-main branches onto the working change
    aliases.herd = ["rebase" "-r" "'branch_roots() ~ @'" "-d" "@"];
    revset-aliases = {
      "branch_roots()" = "'all:roots(::branches() ~ ::main)'";
    };
    signing.key = pubkey;
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
  services.pueue.enable = true;
  programs.bottom.enable = true; # -- Better than htop by a lot
  programs.bottom.settings = {
    flags = {
      regex = true;
      battery = has_prop "platform.laptop";
      mem_as_value = true; # -- Values as MB/GB
      tree = true; # -- For process list
      show_table_scroll_position = true;
      enable_gpu = (has_prop "platform.laptop")
                || (has_prop "platform.desktop");
      enable_cache_memory = true;
    };
  };
  home.packages = with pkgs; [
    # Need to pass agenix through home-manager's extraSpecialArgs
    # agenix.packages.x86_64-linux.agenix
    rage
    atool
    du-dust
    neofetch
    unzip
    zip
    xclip
    whois
    ventoy-full
    glow
    vhs
    watchman
    imagemagick
    cosign
    gitsign
    killall
  ];

  home.stateVersion = "23.11";
}

