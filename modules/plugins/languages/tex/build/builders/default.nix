{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib.options) mkOption;
  inherit (lib.types) enum listOf package str;
  inherit (builtins) attrNames;

  cfg = config.vim.languages.tex;
in
{
  imports = [
    # ./custom.nix
    ./tectonic.nix
  ];

  options.vim.languages.tex.build.builder = {
    name = mkOption {
      type = enum (attrNames cfg.build.builders);
      default = "latexmk";
      description = ''
        The tex builder to use.

        This is just the default custom option. By setting any of the
        builders to true, this will be overwritten by that builder's
        parameters.
      '';
    };
    args = mkOption {
      type = listOf str;
      default = [
        "-pdf"
        "%f"
      ];
      description = ''
        The list of args to pass to the builder.

        This is just the default custom option. By setting any of the
        builders to true, this will be overwritten by that builder's
        parameters.
      '';
    };
    package = mkOption {
      type = package;
      default = (pkgs.texlive.withPackages (ps: [ ps.latexmk ]));
      description = ''
        The tex builder package to use.

        This is just the default custom option. By setting any of the
        builders to true, this will be overwritten by that builder's
        parameters.
      '';
    };
    executable = mkOption {
      type = str;
      default = "latexmk";
      description = ''
        The tex builder executable to use.

        This is just the default custom option. By setting any of the
        builders to true, this will be overwritten by that builder's
        parameters.
      '';
    };
  };
}

