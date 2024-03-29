{ lib }: (prev: final: {
  khionu = lib.recurseIntoAttrs {
    neovim = prev.callPackage ./khionu/neovim { };
  };
})
