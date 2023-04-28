final: prev: {
  cosmic-dock = let nixpkgs = prev.fetchgit (builtins.fromJSON ''{
      "url": "https://github.com/nurelin/nixpkgs",
      "rev": "d7bcff0bd40918a8d96cf68f2b766f987fad900a",
      "sha256": "1r2w6iq80ga8kspspnblk3zqbl1kfn96824cx4iiimzf88r35374"
    }'');
    pkgs = import nixpkgs { inherit (prev) system; };
  in 
  pkgs.callPackage (

{ stdenv, lib, fetchFromGitHub, glib, sassc }:
stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-cosmic-dock";
  version = "unstable-2022-08-27";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic-dock";
    # from branch `master_jammy`
    rev = "6700449db452eea5b2bfa70b3b1f939a45e726c2";
    sha256 = "sha256-QJTq50X4pULoLmCQJRqS8iR84IJp0OFKwGMt4yw7jDY=";
  };

  nativeBuildInputs = [ glib sassc ];

  makeFlags = [ "XDG_DATA_HOME=$(out)/share" "DESTDIR=$(out)" ];

  postPatch = ''
    substituteInPlace ./Makefile \
      --replace 'SHARE_PREFIX = $(DESTDIR)/usr/share' 'SHARE_PREFIX = $(DESTDIR)/share'
  '';

  passthru = {
    extensionUuid = "cosmic-dock@system76.com";
    extensionPortalSlug = "cosmic-dock";
  };

  meta = with lib; {
    description = "Cosmic Dock (Pop!_OS fork of Ubuntu Dock)";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ Enzime ];
    homepage = "https://github.com/pop-os/cosmic-dock";
  };
}) {}; }
