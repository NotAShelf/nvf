{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.binds) addDescriptionsToMappings mkSetLuaBinding;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.lsp;
  self = import ./lspsaga.nix {inherit config lib;};

  mappingDefinitions = self.options.vim.lsp.lspsaga.mappings;
  mappings = addDescriptionsToMappings cfg.lspsaga.mappings mappingDefinitions;
in {
  config = mkIf (cfg.enable && cfg.lspsaga.enable) {
    vim = {
      startPlugins = ["lspsaga-nvim"];

      pluginRC.lspsaga = entryAnywhere ''
        require('lspsaga').init_lsp_saga(${toLuaObject cfg.lspsaga.setupOpts})
      '';

      maps = {
        visual = mkSetLuaBinding mappings.codeAction "require('lspsaga.codeaction').range_code_action";
        normal = mkMerge [
          (mkSetLuaBinding mappings.lspFinder "require('lspsaga.provider').lsp_finder")
          (mkSetLuaBinding mappings.renderHoveredDoc "require('lspsaga.hover').render_hover_doc")

          (mkSetLuaBinding mappings.smartScrollUp "function() require('lspsaga.action').smart_scroll_with_saga(-1) end")
          (mkSetLuaBinding mappings.smartScrollDown "function() require('lspsaga.action').smart_scroll_with_saga(1) end")

          (mkSetLuaBinding mappings.rename "require('lspsaga.rename').rename")
          (mkSetLuaBinding mappings.previewDefinition "require('lspsaga.provider').preview_definition")

          (mkSetLuaBinding mappings.showLineDiagnostics "require('lspsaga.diagnostic').show_line_diagnostics")
          (mkSetLuaBinding mappings.showCursorDiagnostics "require('lspsaga.diagnostic').show_cursor_diagnostics")

          (mkSetLuaBinding mappings.nextDiagnostic "require('lspsaga.diagnostic').navigate('next')")
          (mkSetLuaBinding mappings.previousDiagnostic "require('lspsaga.diagnostic').navigate('prev')")

          (mkSetLuaBinding mappings.codeAction "require('lspsaga.codeaction').code_action")
          (mkIf (!cfg.lspSignature.enable) (mkSetLuaBinding mappings.signatureHelp "require('lspsaga.signaturehelp').signature_help"))
        ];
      };
    };
  };
}
