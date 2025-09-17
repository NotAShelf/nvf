{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
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
        else {
          inherit (cfg) layout opts;
        };
    in ''
      require('alpha').setup(${toLuaObject setupOpts})
    '';

    assertions = [
      {
        assertion = themeDefined || layoutDefined;
        message = ''
          One of 'theme' or 'layout' should be defined in Alpha configuration.
        '';
      }
      {
        assertion = !(themeDefined && layoutDefined);
        message = ''
          'theme' and 'layout' cannot be defined at the same time.
        '';
      }
    ];
  };
}
