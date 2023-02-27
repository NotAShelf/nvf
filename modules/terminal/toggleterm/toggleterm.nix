{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.terminal.toggleterm;
in {
  options.vim.terminal.toggleterm = {
    enable = mkEnableOption "Enable toggleterm as a replacement to built-in terminal command";
    direction = mkOption {
      type = types.enum ["horizontal" "vertical" "tab" "float"];
      default = "horizontal";
      description = "Direction of the terminal";
    };
    enable_winbar = mkOption {
      type = types.bool;
      default = false;
      description = "Enable winbar";
    };
  };
}
