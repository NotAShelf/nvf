{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib.options) mkOption mkEnableOption;
  inherit
    (lib.types)
    bool
    enum
    ints
    listOf
    package
    str
    ;
  inherit
    (builtins)
    attrNames
    concatLists
    concatStringsSep
    elem
    elemAt
    filter
    hasAttr
    isAttrs
    length
    map
    throw
    toString
    ;

  cfg = config.vim.languages.tex;
in
{
  imports = [
    ./custom.nix
    ./tectonic.nix
  ];

  options.vim.languages.tex.build.builder = {
    name = mkOption {
      type = enum (attrNames cfg.build.builders);
      default = "tectonic";
      description = "The tex builder to use";
    };
    args = mkOption {
      type = listOf str;
      default = [];
      description = "The list of args to pass to the builder";
    };
    package = mkOption {
      type = package;
      default = cfg.build.builders.tectonic.package;
      description = "The tex builder package to use";
    };
    executable = mkOption {
      type = str;
      default = cfg.build.builders.tectonic.executable;
      description = "The tex builder executable to use";
    };
  };
}

