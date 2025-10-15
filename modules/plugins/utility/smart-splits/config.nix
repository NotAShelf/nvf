{
  config,
  options,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

  cfg = config.vim.utility.smart-splits;
  inherit (options.vim.utility.smart-splits) keymaps;
  mkSmartSplitKey = act: let
    key = cfg.keymaps.${act};
  in
    lib.optional (key != null) {
      inherit key;
      desc = keymaps.${act}.description;
      action = ''function() require('smart-splits').${act}() end'';
      mode = "n";
      lua = true;
    };
in {
  config = mkIf cfg.enable {
    vim = {
      lazy.plugins.smart-splits = {
        package = "smart-splits";
        setupModule = "smart-splits";
        inherit (cfg) setupOpts;

        # plugin needs to be loaded right after startup so that the multiplexer detects vim running in the pane
        event = ["DeferredUIEnter"];

        keys = lib.flatten [
          (mkSmartSplitKey "resize_left")
          (mkSmartSplitKey "resize_down")
          (mkSmartSplitKey "resize_up")
          (mkSmartSplitKey "resize_right")
          (mkSmartSplitKey "move_cursor_left")
          (mkSmartSplitKey "move_cursor_down")
          (mkSmartSplitKey "move_cursor_up")
          (mkSmartSplitKey "move_cursor_right")
          (mkSmartSplitKey "move_cursor_previous")
          (mkSmartSplitKey "swap_buf_left")
          (mkSmartSplitKey "swap_buf_down")
          (mkSmartSplitKey "swap_buf_up")
          (mkSmartSplitKey "swap_buf_right")
        ];
      };
    };
  };
}
