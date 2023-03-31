{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.assistant.tabnine = {
    enable = mkEnableOption "Enable TabNine assistant";

    disable_auto_comment = mkOption {
      type = types.bool;
      default = true;
      description = "Disable auto comment";
    };

    accept_keymap = mkOption {
      type = types.str;
      default = "<Tab>";
      description = "Accept keymap";
    };

    dismiss_keymap = mkOption {
      type = types.str;
      default = "<C-]>";
      description = "Dismiss keymap";
    };

    debounce_ms = mkOption {
      type = types.int;
      default = 800;
      description = "Debounce ms";
    };

    execlude_filetypes = mkOption {
      type = types.listOf types.str;
      default = ["TelescopePrompt" "NvimTree" "alpha"];
      description = "Execlude filetypes";
    };
  };
}
