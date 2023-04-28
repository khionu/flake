final: prev: {
  pop-cosmic = let nixpkgs = prev.fetchgit (builtins.fromJSON ''{
      "url": "https://github.com/nurelin/nixpkgs",
      "rev": "d7bcff0bd40918a8d96cf68f2b766f987fad900a",
      "sha256": "1r2w6iq80ga8kspspnblk3zqbl1kfn96824cx4iiimzf88r35374"
    }'');
    pkgs = import nixpkgs { inherit (prev) system; };
  in 
  pkgs.callPackage (
{ stdenv, lib, fetchFromGitHub, glib }:

stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-pop-cosmic";
  version = "unstable-2022-08-27";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "cosmic";
    # from branch `master_jammy`
    rev = "8b83057da3be862a08dfbe5009da6a64eba22395";
    sha256 = "sha256-gt7i5J6Ca4+sYzjh22EwvtiGOUuH0oeRaA6l2T7RMrY=";
  };

  nativeBuildInputs = [ glib ];

  makeFlags = [ "XDG_DATA_HOME=$(out)/share" ];

  passthru = {
    extensionUuid = "pop-cosmic@system76.com";
    extensionPortalSlug = "pop-cosmic";
  };

  meta = with lib; {
    description = "Computer Operating System Main Interface Components";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    maintainers = with maintainers; [ Enzime ];
    homepage = "https://github.com/pop-os/cosmic";
  };
}) {}; }
