{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) int float;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline;
in {
  options.vim.visuals.tiny-devicons-auto-colors = {
    enable = mkEnableOption "alternative nvim-web-devicons icon colors [tiny-devicons-auto-colors]";

    setupOpts = mkPluginSetupOption "tiny-devicons-auto-colors" {
      factors = {
        lightness = mkOption {
          type = float;
          default = 1.76;
          description = "Lightness factor of icons";
        };

        chroma = mkOption {
          type = int;
          default = 1;
          description = "Chroma factor of icons";
        };

        hue = mkOption {
          type = float;
          default = 1.25;
          description = "Hue factor of icons";
        };

        cache = {
          enabled = mkEnableOption "caching of icon colors. This will greatly improve performance" // {default = true;};
          path = mkOption {
            type = luaInline;
            default = mkLuaInline "vim.fn.stdpath(\"cache\") .. \"/tiny-devicons-auto-colors-cache.json\"";
            description = "Path to the cache file";
          };
        };
      };
    };
  };
}
