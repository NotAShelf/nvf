{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
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
    lazygit = {
      enable = mkEnableOption "Enable LazyGit integration";
      direction = mkOption {
        type = types.enum ["horizontal" "vertical" "tab" "float"];
        default = "float";
        description = "Direction of the lazygit window";
      };
    };
  };
}
