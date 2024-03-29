# Courtesy of Hazel Weakly
# https://github.com/hazelweakly/nixos-configs/blob/main/packages/neovim.nix

{ lib, pkgs, wrapNeovimUnstable, neovim-unwrapped, stdenv, neovimUtils, vimUtils, vimPlugins,
  neovimPackages ? with pkgs; [
    bat      black    cargo    direnv   eza      git      gnumake  gopls    hadolint isort    jq
    lexical  nil      nodejs   pyright  shfmt    stylua   taplo    watchman yarn
    actionlint       docker-ls        neovim-remote    nixpkgs-fmt      rust-analyzer 
    shellcheck       shellharden      terraform        terraform-ls     tree-sitter
    lua-language-server                       neovim-unwrapped.lua
    nodePackages.bash-language-server         nodePackages.prettier
    nodePackages.prettier_d_slim              nodePackages.typescript-language-server
    nodePackages.vscode-langservers-extracted yaml-language-server
  ]
}:

let
  isBroken = pkg: (builtins.tryEval (builtins.deepSeq pkg.outPath pkg)).success;
  nonBrokenPkgs = builtins.concatMap (p: lib.optionals (isBroken p) [ p ]);
  path = builtins.sort (a: b: a.name < b.name) (nonBrokenPkgs [
    stdenv.cc
  ] ++ neovimPackages);

  # Doing it the non obvious way like this automatically collects all the grammar dependencies for us.
  packDirArgs.myNeovimPackages = { start = [ (vimPlugins.nvim-treesitter.withPlugins (_: vimPlugins.nvim-treesitter.allGrammars)) ]; };
  treeSitterPlugin = vimUtils.packDir packDirArgs;

  args.wrapperArgs = config.wrapperArgs ++ [ "--prefix" "PATH" ":" "${lib.makeBinPath path}" ] ++ [ "--set" "TREESITTER_PLUGIN" treeSitterPlugin ];
  dotfiles = ./dots;

  config = neovimUtils.makeNeovimConfig {
    extraLuaPackages = p: [ p.luarocks ];
    withNodeJs = true;
    withRuby = false;
    vimAlias = true;
    viAlias = true;
    wrapRc = false;
  };

  pkg = wrapNeovimUnstable
    (neovim-unwrapped.overrideAttrs
      (o: { buildInputs = (o.buildInputs or [ ]) ++ [ stdenv.cc.cc.lib ]; }))
    (config // args);
in

pkg // {
  passthru = (pkg.passthru or { }) // {
    inherit args; inherit (pkg) override; inherit dotfiles;
  };
}
