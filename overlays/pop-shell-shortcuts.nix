final: prev: {
   pop-shell-shortcuts = let nixpkgs = prev.fetchgit (builtins.fromJSON ''{
      "url": "https://github.com/nurelin/nixpkgs",
      "rev": "d7bcff0bd40918a8d96cf68f2b766f987fad900a",
      "sha256": "1r2w6iq80ga8kspspnblk3zqbl1kfn96824cx4iiimzf88r35374"
    }'');
    pkgs = import nixpkgs { inherit (prev) system; };
  in 
  pkgs.callPackage (
{ lib, stdenv, fetchFromGitHub, rustPlatform, pkg-config, gtk3 }:

stdenv.mkDerivation rec {
  pname = "pop-shell-shortcuts";
  version = "unstable-2021-10-02";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "shell-shortcuts";
    rev = "005f76c8e59d924a7edb59a2d08030d439b7fd45";
    sha256 = "sha256-/o6sQ/EieIbZrD7p1dwYOQ+uBsk+zf3vjnPXOcD890Q=";
  };

  cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-SySh4/xjP+KnuL3x+IFQUyLgpI3hyshi3h8L5m5ZXOk=";
  };

  nativeBuildInputs = [ pkg-config rustPlatform.cargoSetupHook rustPlatform.rust.cargo ];
  buildInputs = [ gtk3 ];

  installFlags = [ "prefix=$(out)" "DESTDIR=" ];

  meta = with lib; {
    description = "Application for displaying and demoing Pop Shell shortcuts";
    license = licenses.gpl3Only;
    homepage = "https://github.com/pop-os/shell-shortcuts";
    platforms = platforms.linux;
    maintainers = with maintainers; [ Enzime ];
  };
}) {}; }
