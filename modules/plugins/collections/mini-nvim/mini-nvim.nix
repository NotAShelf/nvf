{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.types) attrsOf submodule;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.collections.mini-nvim = {
    enable = mkEnableOption "mini.nvim, a collection of quality-of-life modules";
    modules = mkOption {
      type = attrsOf (submodule {
        options = {
          setupOpts = mkPluginSetupOption "mini.nvim plugin" {};
        };
      });
      default = {};
      example =
        literalExpression
        ''
          {
            files = {};
            sessions = {
              autoread = true;
              autowrite = true;
            };
          }
        '';
    };
  };
}
