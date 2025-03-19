{
  lib,
  config,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (builtins) typeOf tryEval;

  cfg = config.vim.autocomplete;
  getPluginName = plugin:
    if typeOf plugin == "string"
    then plugin
    else if (plugin ? pname && (tryEval plugin.pname).success)
    then plugin.pname
    else plugin.name;
in {
  config.vim = mkIf cfg.enableSharedCmpSources {
    startPlugins = ["rtp-nvim"];
    lazy.plugins =
      mapListToAttrs (package: {
        name = getPluginName package;
        value = {
          inherit package;
          lazy = true;
          after = ''
            local path = vim.fn.globpath(vim.o.packpath, 'pack/*/opt/${getPluginName package}')
            require("rtp_nvim").source_after_plugin_dir(path)
          '';
        };
      })
      cfg.nvim-cmp.sourcePlugins;
  };
}
