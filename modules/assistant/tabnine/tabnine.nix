{lib, ...}: let
  inherit (lib) mkEnableOption mkOption types mkMappingOption;
in {
  options.vim.assistant.tabnine = {
    enable = mkEnableOption "Tabnine assistant";

    disable_auto_comment = mkOption {
      type = types.bool;
      default = true;
      description = "Disable auto comment";
    };

    mappings = {
      accept = mkMappingOption "Accept [Tabnine]" "<Tab>";
      dismiss = mkMappingOption "Dismiss [Tabnine]" "<C-]>";
    };

    debounce_ms = mkOption {
      type = types.int;
      default = 800;
      description = "Debounce ms";
    };

    exclude_filetypes = mkOption {
      type = types.listOf types.str;
      default = ["TelescopePrompt" "NvimTree" "alpha"];
      description = "Exclude filetypes";
    };
  };
}
