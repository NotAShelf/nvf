{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption;
  inherit (lib.types) nullOr str;
in {
  config.vim.lib = {
    mkMappingOption = pluginName: description: default:
      mkOption {
        type = nullOr str;
        default =
          if config.vim.vendoredKeymaps.enable
          then default
          else null;
        description = "${description} [${pluginName}]";
      };
  };
}
