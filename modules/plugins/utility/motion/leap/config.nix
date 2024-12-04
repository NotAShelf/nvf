{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.nvim.binds) mkKeymap;

  cfg = config.vim.utility.motion.leap;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["vim-repeat"];
      lazy.plugins.leap-nvim = {
        package = "leap-nvim";
        keys = [
          (mkKeymap ["n" "o" "x"] cfg.mappings.leapForwardTo "<Plug>(leap-forward-to)" {desc = "Leap forward to";})
          (mkKeymap ["n" "o" "x"] cfg.mappings.leapBackwardTo "<Plug>(leap-backward-to)" {desc = "Leap backward to";})
          (mkKeymap ["n" "o" "x"] cfg.mappings.leapForwardTill "<Plug>(leap-forward-till)" {desc = "Leap forward till";})
          (mkKeymap ["n" "o" "x"] cfg.mappings.leapBackwardTill "<Plug>(leap-backward-till)" {desc = "Leap backward till";})
          (mkKeymap ["n" "o" "x"] cfg.mappings.leapFromWindow "<Plug>(leap-from-window)" {desc = "Leap from window";})
        ];

        after = ''
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

      binds.whichKey.register."<leader>s" = mkDefault "+Leap";
    };
  };
}
