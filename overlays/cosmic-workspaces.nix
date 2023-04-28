final: prev: {
  cosmic-workspaces = let nixpkgs = prev.fetchgit (builtins.fromJSON ''{
      "url": "https://github.com/nurelin/nixpkgs",
      "rev": "d7bcff0bd40918a8d96cf68f2b766f987fad900a",
      "sha256": "1r2w6iq80ga8kspspnblk3zqbl1kfn96824cx4iiimzf88r35374"
    }'');
    pkgs = import nixpkgs { inherit (prev) system; };
  in 
  pkgs.callPackage (
{ stdenv, lib, fetchFromGitHub, glib }:

stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-cosmic-workspaces";
  version = "unstable-2022-08-27";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-workspaces";
    # from branch `master_jammy`
    rev = "c5f2c5dced0adc4bb19719454fd90becd5c9e85a";
    sha256 = "sha256-S4oXFkxfMOm69uvyZbGZxX544s6gX6+TCIX+WyC7ImU=";
  };

  nativeBuildInputs = [ glib ];

  makeFlags = [ "XDG_DATA_HOME=$(out)/share" ];

  passthru = {
    extensionUuid = "cosmic-workspaces@system76.com";
    extensionPortalSlug = "cosmic-workspaces";
  };

  meta = with lib; {
    description = "Vertically stacked workspaces (Pop!_OS fork)";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ Enzime ];
    homepage = "https://github.com/pop-os/cosmic-workspaces";
  };
}) {}; }
