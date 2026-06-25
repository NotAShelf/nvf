{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.lsp.presets.typescript-language-server;
in {
  options.vim.lsp.presets.typescript-language-server = {
    enable = mkLspPresetEnableOption "typescript-language-server" "TypeScript" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.typescript-language-server = {
      enable = true;
      cmd = [(getExe pkgs.typescript-language-server) "--stdio"];
      root_markers = [".git" "tsconfig.json" "package.json"];
      init_options = {hostInfo = "neovim";};
      handlers = {
        # handle rename request for certain code actions like extracting functions / types
        "_typescript.rename" = mkLuaInline ''
          function(_, result, ctx)
            local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
            vim.lsp.util.show_document({
              uri = result.textDocument.uri,
              range = {
                start = result.position,
                ['end'] = result.position,
              },
            }, client.offset_encoding)
            vim.lsp.buf.rename()
            return vim.NIL
          end
        '';
      };
      on_attach = mkLuaInline ''
        function(client, bufnr)
          -- ts_ls provides `source.*` code actions that apply to the whole file. These only appear in
          -- `vim.lsp.buf.code_action()` if specified in `context.only`.
          vim.api.nvim_buf_create_user_command(0, 'LspTypescriptSourceAction', function()
            local source_actions = vim.tbl_filter(function(action)
              return vim.startswith(action, 'source.')
            end, client.server_capabilities.codeActionProvider.codeActionKinds)

            vim.lsp.buf.code_action({
              context = {
                only = source_actions,
              },
            })
          end, {})
        end
      '';
    };
  };
}
