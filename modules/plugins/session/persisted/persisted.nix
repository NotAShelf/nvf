{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
  inherit (config.vim.lib) mkMappingOption;
in {
  options.vim.session.persisted = {
    enable = mkEnableOption "persisted nvim session manager";

    mappings = {
      load = mkMappingOption "load session" "<leader>qs";
      select = mkMappingOption "select session" "<leader>ql";
    };

    setupOpts = mkPluginSetupOption "persisted" {};
  };
}
