{
  pkgs,
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
      package = mkOption {
        type = with types; nullOr package;
        default = pkgs.lazygit;
        description = "The package that should be used for lazygit. Setting it to null will attempt to use lazygit from your PATH";
      };
    };
  };
}
