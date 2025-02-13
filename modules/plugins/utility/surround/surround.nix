{
  lib,
  config,
  ...
}: let
  inherit (lib.options) mkOption;
  inherit (lib.types) bool str;
  inherit (lib.nvim.types) mkPluginSetupOption;

  cfg = config.vim.utility.surround;
  vendoredKeybinds = {
    insert = "<C-g>z";
    insert_line = "<C-g>Z";
    normal = "gz";
    normal_cur = "gZ";
    normal_line = "gzz";
    normal_cur_line = "gZZ";
    visual = "gz";
    visual_line = "gZ";
    delete = "gzd";
    change = "gzr";
    change_line = "gZR";
  };

  mkKeymapOption = name: default:
    mkOption {
      description = "keymap for ${name}";
      type = str;
      default =
        if cfg.useVendoredKeybindings
        then vendoredKeybinds.${name}
        else default;
    };
in {
  options.vim.utility.surround = {
    enable = mkOption {
      type = bool;
      default = false;
      description = ''
        nvim-surround: add/change/delete surrounding delimiter pairs with ease.
        Note that the default mappings deviate from upstream to avoid conflicts
        with nvim-leap.
      '';
    };
    setupOpts = mkPluginSetupOption "nvim-surround" {
      keymaps = {
        insert = mkKeymapOption "insert" "<C-g>s";
        insert_line = mkKeymapOption "insert_line" "<C-g>S";
        normal = mkKeymapOption "normal" "ys";
        normal_cur = mkKeymapOption "normal_cur" "yss";
        normal_line = mkKeymapOption "normal_line" "yS";
        normal_cur_line = mkKeymapOption "normal_cur_line" "ySS";
        visual = mkKeymapOption "visual" "S";
        visual_line = mkKeymapOption "visual_line" "gS";
        delete = mkKeymapOption "delete" "ds";
        change = mkKeymapOption "change" "cs";
        change_line = mkKeymapOption "change_line" "cS";
      };
    };

    useVendoredKeybindings = mkOption {
      type = bool;
      default = true;
      description = "Use alternative set of keybindings that avoids conflicts with other popular plugins, e.g. nvim-leap";
    };
  };
}
