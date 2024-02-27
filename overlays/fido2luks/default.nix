{ lib
, rustPlatform
, fetchFromGitHub
, cryptsetup
, pkg-config
}:

rustPlatform.buildRustPackage rec {
  pname = "fido2luks";
  version = "0.2.21";

  src = ./vendored;

  nativeBuildInputs = [ pkg-config rustPlatform.bindgenHook ];

  buildInputs = [ cryptsetup ];

  cargoSha256 = "sha256-6SMlh/UdcmqRsX0QXDmKKccYJIPZGLThmF7hqz/nOIA=";

  meta = with lib; {
    description = "Decrypt your LUKS partition using a FIDO2 compatible authenticator";
    homepage = "https://github.com/shimunn/fido2luks";
    license = licenses.mpl20;
    maintainers = with maintainers; [ prusnak mmahut ];
    platforms = platforms.linux;
  };
}
