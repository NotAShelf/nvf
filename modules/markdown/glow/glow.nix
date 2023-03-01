{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.markdown.glow;
in {
  options.vim.markdown.glow = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable markdown preview in neovim with glow";
    };
    border = mkOption {
      type = types.enum ["shadow" "rounded" "single" "double" "none"];
      default = "double";
      description = "Border style for glow preview";
    };

    # style should be either light or dark
    style = mkOption {
      type = types.enum ["light" "dark"];
      default = "dark";
      description = "Style for glow preview";
    };

    pager = mkOption {
      type = types.bool;
      default = false;
      description = "Enable pager for glow preview";
    };
  };
}
