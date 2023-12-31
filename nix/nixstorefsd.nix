{ fuse3
, macfuse-stubs
, stdenv
, pkg-config
, openssl
, zstd
, cargo-flamegraph
, rustPlatform
, lib
, runCommand
, fetchurl
, clippy
, path
, enableLint ? false
}:
let
  fuse = if stdenv.isDarwin then macfuse-stubs else fuse3;
in
rustPlatform.buildRustPackage
  {
    pname = "nixstorefsd";
    version = "0.0.1";
    src = runCommand "src" { } ''
      install -D ${../Cargo.toml} $out/Cargo.toml
      install -D ${../Cargo.lock} $out/Cargo.lock
      cp -r ${../src} $out/src
    '';

    buildInputs = [ zstd fuse ];
    nativeBuildInputs = [ openssl pkg-config ] ++ lib.optional enableLint clippy;

    cargoLock = {
      lockFile = ../Cargo.lock;
    };
    meta = with lib; {
      description = "Provides build shell that can automatically figure out dependencies";
      homepage = "https://github.com/RaitoBezarius/nixstorefs";
      license = licenses.mit;
    };
  } // lib.optionalAttrs enableLint {
  buildPhase = ''
    cargo clippy --all-targets --all-features -- -D warnings
    if grep -R 'dbg!' ./src; then
      echo "use of dbg macro found in code!"
      false
    fi
  '';

  installPhase = ''
    touch $out
  '';

}
