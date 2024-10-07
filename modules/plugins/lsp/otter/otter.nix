{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.nvim.binds) mkMappingOption;
  inherit (lib.types) bool str listOf;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.lsp = {
    otter-nvim = {
      enable = mkEnableOption ''
        lsp features and a code completion source for code embedded in other documents [otter-nvim]
      '';
      mappings = {
        toggle = mkMappingOption "Activate LSP on Cursor Position [otter-nvim]" "<leader>lo";
      };
      setupOpts = mkPluginSetupOption "otter.nvim" {
        lsp = {
          diagnostic_update_event = mkOption {
            type = listOf str;
            default = ["BufWritePost"];
            description = ''
              `:h events` that cause the diagnostic to update.
              Set to: {"BufWritePost", "InsertLeave", "TextChanged" }
              for less performant but more instant diagnostic updates
            '';
          };
        };
        buffers = {
          set_filetype = mkOption {
            type = bool;
            default = false;
            description = ''
              if set to true, the filetype of the otterbuffers will be set. Other wide only
              the autocommand of lspconfig that attaches the language server will be
              executed without stting the filetype
            '';
          };
          write_to_disk = mkOption {
            type = bool;
            default = false;
            description = ''
              write <path>.otter.<embedded language extension> files to disk on save of main buffer.
              Useful for some linters that require actual files.
              Otter files are deleted on quit or main buffer close
            '';
          };
        };
        strip_wrapping_quote_characters = mkOption {
          type = listOf str;
          default = ["'" ''"'' "`"];
          description = ''
          '';
        };
        handle_leading_whitespace = mkOption {
          type = bool;
          default = false;
          description = ''
            otter may not work the way you expect when entire code blocks are indented
            (eg. in Org files) When true, otter handles these cases fully.
          '';
        };
      };
    };
  };
}
