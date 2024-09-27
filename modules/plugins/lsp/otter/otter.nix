{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.binds) mkMappingOption;
in {
  options.vim.lsp = {
    trouble = {
      enable = mkEnableOption "Otter LSP Injector";

      mappings = {
        toggle = mkMappingOption "Activate LSP on Cursor Position [otter]" "<leader>oa";
      };
    };
  };
}
