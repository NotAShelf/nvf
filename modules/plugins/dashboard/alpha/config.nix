{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.dashboard.alpha;
  themeDefined = cfg.theme != null;
  layoutDefined = cfg.layout != [];
in {
  config = mkIf cfg.enable {
    vim = {
      visuals.nvim-web-devicons.enable = true;

      lazy.plugins.alpha-nvim = {
        package = "alpha-nvim";
        setupModule = "alpha";
        setupOpts =
          if themeDefined
          then lib.generators.mkLuaInline "require'alpha.themes.${cfg.theme}'.config"
          else {
            inherit (cfg) layout opts;
          };
        event = ["VimEnter"];
        cmd = ["Alpha" "AlphaRedraw" "AlphaRemap"];
      };
    };

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
