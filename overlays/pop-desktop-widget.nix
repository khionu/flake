final: prev: {
  pop-desktop-widget =
    let nixpkgs = prev.fetchgit (builtins.fromJSON ''{
      "url": "https://github.com/nurelin/nixpkgs",
      "rev": "d7bcff0bd40918a8d96cf68f2b766f987fad900a",
      "sha256": "1r2w6iq80ga8kspspnblk3zqbl1kfn96824cx4iiimzf88r35374"
    }'');
    pkgs = import nixpkgs { inherit (prev) system; };
  in 
    pkgs.callPackage (
    { stdenv, fetchFromGitHub, rustPlatform, lib, pkg-config, glib, gst_all_1, gtk3, libhandy }:

    stdenv.mkDerivation rec {
    pname = "pop-desktop-widget";
    version = "unstable-2022-08-27";

    src = fetchFromGitHub {
    owner = "pop-os";
    repo = "desktop-widget";
# master_jammy branch
    rev = "495e4b9fea1dc9fdf0ab1e2b4773bb8eb5d8555e";
    sha256 = "sha256-1YmEX2SGRWRyWyGjHYHEoWxsTxTZhNp58bSKzgw/Kmw=";
    };

    cargoDeps = rustPlatform.fetchCargoTarball {
    inherit src;
    name = "${pname}-${version}";
    hash = "sha256-qhh8/38VQpxUXga1lmrjy07m0wlaOPQMccAKVMqCoj4=";
    };

    nativeBuildInputs = [ pkg-config glib rustPlatform.cargoSetupHook rustPlatform.rust.cargo ];
    buildInputs = [ gst_all_1.gstreamer gtk3 libhandy ];

    buildFlags = [ "prefix=$(out)" "DESTDIR=" ];
    installFlags = [ "prefix=$(out)" "DESTDIR=" ];

    postInstall = ''
	    cd $out/lib
	    ln -s libpop_desktop_widget.so libpop_desktop_widget.so.0
	    '';

    meta = with lib; {
	    description = "GTK desktop settings widget for Pop!_OS";
	    maintainers = with maintainers; [ Enzime ];
	    license = licenses.mit;
	    homepage = "https://github.com/pop-os/desktop-widget";
    };
    }
    ) {};
       }
