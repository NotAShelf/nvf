{
  pkgs,
  stdenv,
}: let
  formatter-env = with pkgs;
    bundlerEnv {
      name = "Gem dependencies";
      inherit self;
      ruby = ruby_3_2;
      gemdir = ./.;

      gemConfig =
        pkgs.defaultGemConfig
        // {
          nokogiri = attrs: {
            buildFlags = ["--use-system-libraries"]; # "--with-zlib-include=${pkgs.zlib}/include/libxml2"];
          };
        };
    };
in
  stdenv.mkDerivation {
    name = "Format environment";
    nativeBuildInputs = [
      pkgs.libxslt
      pkgs.zlib
      pkgs.libxml2
      pkgs.pkg-config
    ];

    # Add the derivation to the PATH
    buildInputs = [
      pkgs.libxslt
      pkgs.zlib
      pkgs.libxml2
      pkgs.pkg-config
      formatter-env
    ];
  }
