{lib}:
with lib; let
  # Plugin must be same as input name from flake.nix
  availablePlugins = [
    # TODO: sort by category
    "nvim-treesitter-context"
    "gitsigns-nvim"
    "plenary-nvim"
    "nvim-lspconfig"
    "nvim-treesitter"
    "lspsaga"
    "lspkind"
    "nvim-lightbulb"
    "lsp-signature"
    "nvim-tree-lua"
    "nvim-bufferline-lua"
    "lualine"
    "nvim-compe"
    "nvim-autopairs"
    "nvim-ts-autotag"
    "nvim-web-devicons"
    "tokyonight"
    "bufdelete-nvim"
    "nvim-cmp"
    "cmp-nvim-lsp"
    "cmp-buffer"
    "cmp-vsnip"
    "cmp-path"
    "cmp-treesitter"
    "crates-nvim"
    "vim-vsnip"
    "nvim-code-action-menu"
    "trouble"
    "none-ls"
    "which-key"
    "indent-blankline"
    "nvim-cursorline"
    "sqls-nvim"
    "glow-nvim"
    "telescope"
    "rust-tools"
    "onedark"
    "catppuccin"
    "dracula"
    "oxocarbon"
    "gruvbox"
    "minimap-vim"
    "dashboard-nvim"
    "alpha-nvim"
    "scrollbar-nvim"
    "codewindow-nvim"
    "nvim-notify"
    "cinnamon-nvim"
    "cheatsheet-nvim"
    "ccc"
    "cellular-automaton"
    "neocord"
    "icon-picker-nvim"
    "dressing-nvim"
    "orgmode-nvim"
    "obsidian-nvim"
    "vim-markdown"
    "tabular"
    "toggleterm-nvim"
    "noice-nvim"
    "nui-nvim"
    "copilot-lua"
    "tabnine-nvim"
    "nvim-session-manager"
    "gesture-nvim"
    "comment-nvim"
    "kommentary"
    "mind-nvim"
    "fidget-nvim"
    "diffview-nvim"
    "todo-comments"
    "flutter-tools"
    "flutter-tools-patched"
    "hop-nvim"
    "leap-nvim"
    "modes-nvim"
    "vim-repeat"
    "smartcolumn"
    "project-nvim"
    "neodev-nvim"
    "elixir-ls"
    "elixir-tools"
    "nvim-colorizer-lua"
    "vim-illuminate"
    "nvim-surround"
    "nvim-dap"
    "nvim-dap-ui"
    "nvim-navic"
    "nvim-navbuddy"
    "copilot-cmp"
    "lsp-lines"
    "vim-dirtytalk"
    "highlight-undo"
    "nvim-docs-view"
  ];
  # You can either use the name of the plugin or a package.
  pluginType = with types;
    nullOr (
      either
      package
      (enum availablePlugins)
    );

  pluginsType = types.listOf pluginType;

  extraPluginType = with types;
    submodule {
      options = {
        package = mkOption {
          type = pluginType;
          description = "Plugin Package.";
        };
        after = mkOption {
          type = listOf str;
          default = [];
          description = "Setup this plugin after the following ones.";
        };
        setup = mkOption {
          type = lines;
          default = "";
          description = "Lua code to run during setup.";
          example = "require('aerial').setup {}";
        };
      };
    };
in {
  inherit extraPluginType;

  pluginsOpt = {
    description,
    default ? [],
  }:
    mkOption {
      inherit description default;
      type = pluginsType;
    };

  # opts is a attrset of options, example:
  # ```
  # mkPluginSetupOption "telescope" {
  #   file_ignore_patterns = mkOption {
  #     description = "...";
  #     type = types.listOf types.str;
  #     default = [];
  #   };
  #   layout_config.horizontal = mkOption {...};
  # }
  # ```
  mkPluginSetupOption = pluginName: opts:
    mkOption {
      description = "Option table to pass into the setup function of " + pluginName;
      default = {};
      type = types.submodule {
        freeformType = with types; attrsOf anything;
        options = opts;
      };
    };
}
