{
  pkgs,
  stdenv,
}: let
  #formatter-env = with pkgs;
  #  bundlerEnv {
  #    name = "Gem dependencies";
  #    # inherit ruby_3_2;
  #    ruby = ruby_3_2;
  #    gemdir = ./.;
  #      gemConfig =
  #        pkgs.defaultGemConfig
  #        // {
  #          nokogiri = attrs: {
  #            buildFlags = ["--use-system-libraries"]; # "--with-zlib-include=${pkgs.zlib}/include/libxml2"];
  #          };
  #        };
  #  };
in
  stdenv.mkDerivation {
    name = "Format environment";

    # nativeBuildInputs = [
    #    pkgs.libxslt
    #    pkgs.zlib
    #    pkgs.libxml2
    #    pkgs.pkg-config
    #    pkgs.rubocop
    #    pkgs.solargraph
    #  ];

    # Add the derivation to the PATH
    buildInputs = [
      pkgs.libxslt
      pkgs.libxml2
      pkgs.rubocop
      pkgs.solargraph

      # formatter-env
    ];
  }
