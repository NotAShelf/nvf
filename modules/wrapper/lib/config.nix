{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption;
  inherit (lib.types) nullOr str;
in {
  config.vim.lib = {
    mkMappingOption = description: default:
      mkOption {
        type = nullOr str;
        default =
          if config.vim.useNvfKeymaps
          then default
          else null;
        inherit description;
      };
  };
}
