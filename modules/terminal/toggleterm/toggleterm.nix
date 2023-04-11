{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.terminal.toggleterm = {
    enable = mkEnableOption "Enable toggleterm as a replacement to built-in terminal command";
    mappings = {
      open = mkOption {
        type = types.nullOr types.str;
        description = "The keymapping to open toggleterm";
        default = "<c-t>";
      };
    };
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
