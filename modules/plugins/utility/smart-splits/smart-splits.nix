{lib, ...}: let
  inherit (lib.options) mkOption;
  inherit (lib.types) bool;
  inherit (lib.nvim.types) mkPluginSetupOption;
  inherit (lib.nvim.binds) mkMappingOption;
in {
  options.vim.utility.smart-splits = {
    enable = mkOption {
      type = bool;
      default = false;
      description = ''
        Whether to enable smart-splits.nvim, a Neovim plugin for smart,
        seamless, directional navigation and resizing of splits.

        Supports tmux, Wezterm, Kitty, and Zellij multiplexer integrations.
      '';
    };

    setupOpts = mkPluginSetupOption "smart-splits" {};

    keymaps = {
      resize_left = mkMappingOption config.vim.enableNvfKeymaps "Resize Window/Pane Left" "<A-h>";
      resize_down = mkMappingOption config.vim.enableNvfKeymaps "Resize Window/Pane Down" "<A-j>";
      resize_up = mkMappingOption config.vim.enableNvfKeymaps "Resize Window/Pane Up" "<A-k>";
      resize_right = mkMappingOption config.vim.enableNvfKeymaps "Resize Window/Pane Right" "<A-l>";
      move_cursor_left = mkMappingOption config.vim.enableNvfKeymaps "Focus Window/Pane on the Left" "<C-h>";
      move_cursor_down = mkMappingOption config.vim.enableNvfKeymaps "Focus Window/Pane Below" "<C-j>";
      move_cursor_up = mkMappingOption config.vim.enableNvfKeymaps "Focus Window/Pane Above" "<C-k>";
      move_cursor_right = mkMappingOption config.vim.enableNvfKeymaps "Focus Window/Pane on the Right" "<C-l>";
      move_cursor_previous = mkMappingOption config.vim.enableNvfKeymaps "Focus Previous Window/Pane" "<C-\\>";
      swap_buf_left = mkMappingOption config.vim.enableNvfKeymaps "Swap Buffer Left" "<leader><leader>h";
      swap_buf_down = mkMappingOption config.vim.enableNvfKeymaps "Swap Buffer Down" "<leader><leader>j";
      swap_buf_up = mkMappingOption config.vim.enableNvfKeymaps "Swap Buffer Up" "<leader><leader>k";
      swap_buf_right = mkMappingOption config.vim.enableNvfKeymaps "Swap Buffer Right" "<leader><leader>l";
    };
  };
}
