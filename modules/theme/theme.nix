{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with lib.attrsets;
with builtins; let
  cfg = config.vim.theme;
  supported_themes = import ./supported_themes.nix;
in {
  options.vim.theme = {
    enable = mkOption {
      type = types.bool;
      description = "Enable Theme";
    };

    name = mkOption {
      type = types.enum (attrNames supported_themes);
      description = "Supported themes can be found in `supported_themes.nix`";
    };

    style = mkOption {
      type = with types; enum supported_themes.${cfg.name}.styles;
      description = "Specific style for theme if it supports it";
    };

    extraConfig = mkOption {
      type = with types; lines;
      description = "Additional lua configuration to add before setup";
    };
  };

  config = mkIf cfg.enable {
    vim.startPlugins = [cfg.name];
    vim.luaConfigRC.themeSetup = nvim.dag.entryBefore ["theme"] cfg.extraConfig;
    vim.luaConfigRC.theme = supported_themes.${cfg.name}.setup {style = cfg.style;};
  };
}
