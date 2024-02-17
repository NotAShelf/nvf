{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf mkMerge mkBinding nvim;

  cfg = config.vim.utility.motion.leap;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = [
      "leap-nvim"
      "vim-repeat"
    ];

    vim.maps.normal = mkMerge [
      (mkBinding cfg.mappings.leapForwardTo "<Plug>(leap-forward-to)" "Leap forward to")
      (mkBinding cfg.mappings.leapBackwardTo "<Plug>(leap-backward-to)" "Leap backward to")
      (mkBinding cfg.mappings.leapFromWindow "<Plug>(leap-from-window)" "Leap from window")
    ];

    vim.maps.operator = mkMerge [
      (mkBinding cfg.mappings.leapForwardTo "<Plug>(leap-forward-to)" "Leap forward to")
      (mkBinding cfg.mappings.leapBackwardTo "<Plug>(leap-backward-to)" "Leap backward to")
      (mkBinding cfg.mappings.leapForwardTill "<Plug>(leap-forward-till)" "Leap forward till")
      (mkBinding cfg.mappings.leapBackwardTill "<Plug>(leap-backward-till)" "Leap backward till")
      (mkBinding cfg.mappings.leapFromWindow "<Plug>(leap-from-window)" "Leap from window")
    ];

    vim.maps.visualOnly = mkMerge [
      (mkBinding cfg.mappings.leapForwardTo "<Plug>(leap-forward-to)" "Leap forward to")
      (mkBinding cfg.mappings.leapBackwardTo "<Plug>(leap-backward-to)" "Leap backward to")
      (mkBinding cfg.mappings.leapForwardTill "<Plug>(leap-forward-till)" "Leap forward till")
      (mkBinding cfg.mappings.leapBackwardTill "<Plug>(leap-backward-till)" "Leap backward till")
      (mkBinding cfg.mappings.leapFromWindow "<Plug>(leap-from-window)" "Leap from window")
    ];

    vim.luaConfigRC.leap-nvim = nvim.dag.entryAnywhere ''
      require('leap').opts = {
        max_phase_one_targets = nil,
        highlight_unlabeled_phase_one_targets = false,
        max_highlighted_traversal_targets = 10,
        case_sensitive = false,
        equivalence_classes = { ' \t\r\n', },
        substitute_chars = {},
        safe_labels = {
          "s", "f", "n", "u", "t", "/",
          "S", "F", "N", "L", "H", "M", "U", "G", "T", "?", "Z"
        },
        labels = {
          "s", "f", "n",
          "j", "k", "l", "h", "o", "d", "w", "e", "m", "b",
          "u", "y", "v", "r", "g", "t", "c", "x", "/", "z",
          "S", "F", "N",
          "J", "K", "L", "H", "O", "D", "W", "E", "M", "B",
          "U", "Y", "V", "R", "G", "T", "C", "X", "?", "Z"
        },
        special_keys = {
          repeat_search = '<enter>',
          next_phase_one_target = '<enter>',
          next_target = {'<enter>', ';'},
          prev_target = {'<tab>', ','},
          next_group = '<space>',
          prev_group = '<tab>',
          multi_accept = '<enter>',
          multi_revert = '<backspace>',
        },
      }
    '';
  };
}
