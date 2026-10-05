{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) either listOf attrs;
  inherit (lib.lists) optional;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline;

  vim = config.vim;
  dapEnabled = vim.debugger.nvim-dap.enable;
  dapUiEnabled = dapEnabled && vim.debugger.nvim-dap.ui.enable;
in {
  options.vim.ui.zen-nvim = {
    enable = mkEnableOption "automatic buffer centering and side-buffer layouts [zen.nvim]";

    setupOpts = mkPluginSetupOption "zen.nvim" {
      top = mkOption {
        type = either luaInline (listOf attrs);
        default =
          [
            {
              filetype = "gitcommit";
              replace = false;
            }
            {filetype = "man";}
            {filetype = "help";}
          ]
          ++ optional vim.git.vim-fugitive.enable {filetype = "fugitive";};
        description = ''
          Top-side buffer integrations. Includes commit messages, manual pages,
          help buffers, and Fugitive when enabled. An explicit list replaces
          these defaults.
        '';
      };

      right = mkOption {
        type = either luaInline (listOf attrs);
        default =
          [
            {
              filetype = "*";
              min_width = 46;
            }
          ]
          ++ optional dapUiEnabled {
            filetype = [
              "dapui_watches"
              "dapui_scopes"
              "dapui_stacks"
              "dapui_breakpoints"
            ];
          };
        description = ''
          Right-side buffer integrations. Includes DAP UI panes when enabled
          and a wildcard minimum width of 46 columns. An explicit list replaces
          these defaults.
        '';
      };

      bottom = mkOption {
        type = either luaInline (listOf attrs);
        default =
          [{filetype = "qf";}]
          ++ optional dapEnabled {filetype = "dap-repl";}
          ++ optional dapUiEnabled {filetype = "dapui_console";}
          ++ optional (vim.lsp.enable && vim.lsp.trouble.enable) {filetype = "trouble";}
          ++ optional vim.ui.noice.enable {filetype = "noice";}
          ++ optional (vim.languages.http.enable && vim.languages.http.extensions.kulala-nvim.enable) {filetype = "kulala_ui";};
        description = ''
          Bottom-side buffer integrations. Includes quickfix buffers and
          enabled DAP, DAP UI, Trouble, Noice, and Kulala panes. An explicit list
          replaces these defaults.
        '';
      };

      left = mkOption {
        type = either luaInline (listOf attrs);
        default =
          [
            {
              filetype = "*";
              min_width = 46;
            }
          ]
          ++ optional vim.git.vim-fugitive.enable {filetype = "fugitiveblame";}
          ++ optional vim.filetree.neo-tree.enable {filetype = "neo-tree";}
          ++ optional vim.utility.undotree.enable {filetype = ["undotree" "diff"];};
        description = ''
          Left-side buffer integrations. Includes enabled Fugitive, Neo-tree,
          and Undotree panes and a wildcard minimum width of 46 columns.

          Set this list explicitly to replace the default layout.
        '';
      };
    };
  };
}
