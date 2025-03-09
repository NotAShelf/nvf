{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.dashboard.alpha;
  themeDefined = cfg.theme != null;
  layoutDefined = cfg.layout != [];
in {
  config = mkIf cfg.enable {
    vim.startPlugins = [
      "alpha-nvim"
      "nvim-web-devicons"
    ];

    vim.pluginRC.alpha = let
      setupOpts =
        if themeDefined
        then lib.generators.mkLuaInline "require'alpha.themes.${cfg.theme}'.config"
        else
          (with cfg; {
            inherit layout opts;
          });
    in ''
      require('alpha').setup(${toLuaObject setupOpts})
    '';

    assertions = [
      {
        assertion = themeDefined || layoutDefined;
        message = ''
          You should either define `theme` or `layout`.
        '';
      }
      {
        assertion = !(themeDefined && layoutDefined);
        message = ''
          You can't define both `theme` and `layout` at the same time.
        '';
      }
    ];
  };
}
