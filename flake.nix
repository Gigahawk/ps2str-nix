{
  description = "Devshell and package definition";

  inputs = {
    # Waiting for https://github.com/NixOS/nixpkgs/pull/336611 to be merged
    nixpkgs.url = "github:Gigahawk/nixpkgs/wiseunpacker";
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      version = "1.05";
    in {
      packages = {
        default = with import nixpkgs { inherit system; };
        stdenv.mkDerivation rec {
          pname = "ps2str";
          inherit version;
          # This little maneuver's gonna cost us 51 years
          src = (pkgs.fetchurl {
            url = "https://archive.org/download/PlayStation2July2005SDKversion3.0.3/PlayStation%202%20July%202005%20SDK%20%28version%203.0.3%29.iso";
            hash = "sha256-G8J/66e3hoNGMV1DYpWuEU7BN/3LagWL46Jc4bq5tAk=";
          });


          nativeBuildInputs = [ pkgs.p7zip pkgs.wiseunpacker ];

          unpackPhase = ''
            7z x "$src"
            WiseUnpacker "Installers/RTLibs&ToolchainSetup.exe"
          '';

          buildPhase = ''
            true
          '';

          installPhase = ''
            runHook preInstall
            install -m755 -D "Installers/RTLibs&ToolchainSetup/MAINDIR/tools/ps2str/linux/ps2str" "$out/bin/ps2str"
            patchelf --set-interpreter "${pkgs.pkgsi686Linux.glibc}/lib/ld-linux.so.2" \
              "$out/bin/ps2str"
            runHook postInstall
          '';
        };
      };
    });
}
