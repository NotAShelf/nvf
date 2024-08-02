{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
  inherit (lib.nvim.binds) mkMappingOption;
in {
  options.vim.lsp.code-actions.fastaction-nvim = {
    enable = mkEnableOption "code actions for Neovim via fastaction.nvim";
    setupOpts = mkPluginSetupOption "fastaction-nvim" {};

    mappings = {
      code_action = mkMappingOption "Displays code action popup [Fastaction.nvim]" "<leader>cfa";
      range_action = mkMappingOption " Displays code actions for visual range [Fastaction.nvim]" "<leader>cra";
    };
  };
}
