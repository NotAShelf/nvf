{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.lsp.dart.flutter-tools = {
    enable = mkEnableOption "Enable flutter-tools for flutter support";

    color = {
      enable = mkEnableOption "Whether or mot to highlight color variables at all";

      highlightBackground = mkOption {
        type = types.bool;
        default = false;
        description = "Highlight the background";
      };

      highlightForeground = mkOption {
        type = types.bool;
        default = false;
        description = "Highlight the foreground";
      };

      virtualText = {
        enable = mkEnableOption "Show the highlight using virtual text";

        character = mkOption {
          type = types.str;
          default = "■";
          description = "Virtual text character to highlight";
        };
      };
    };
  };
}
