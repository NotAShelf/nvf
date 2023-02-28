{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.markdown;
in {
  options.vim.markdown = {
    glow.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable markdown preview in neovim with glow";
    };
  };
}
