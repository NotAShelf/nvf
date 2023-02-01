{lib}:
with lib; let
  # Plugin must be same as input name
  availablePlugins = [
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
    "null-ls"
    "which-key"
    "indent-blankline"
    "nvim-cursorline"
    "sqls-nvim"
    "glow-nvim"
    "telescope"
    "rust-tools"
    "onedark"
    "catppuccin"
  ];

  pluginsType = with types; listOf (nullOr (either (enum availablePlugins) package));
in {
  pluginsOpt = {
    description,
    default ? [],
  }:
    mkOption {
      inherit description default;
      type = pluginsType;
    };
}
