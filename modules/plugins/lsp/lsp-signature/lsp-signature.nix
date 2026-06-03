{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline;
  inherit (lib.generators) mkLuaInline;
in {
  options.vim.lsp = {
    lspSignature = {
      enable = mkEnableOption "lsp signature viewer";
      setupOpts = mkPluginSetupOption "lsp-signature" {
        ignore_error = mkOption {
          type = luaInline;
          description = "Custom error filter.";
          # https://github.com/NotAShelf/nvf/pull/1545#discussion_r3253920092
          defaultText = "Filters out errors that occur more than once, per client";
          default = mkLuaInline ''
            function(err, ctx, config)
              if ctx and ctx.client_id then
                -- upstream default
                local client = vim.lsp.get_client_by_id(ctx.client_id)
                if client and vim.tbl_contains({"rust-analyzer", "clangd"}, client.name) then
                  return true
                end

                -- prevents error spam
                _LSP_SIG_IGNORE_ERR = _LSP_SIG_IGNORE_ERR or {}
                _LSP_SIG_IGNORE_ERR[ctx.client_id] = _LSP_SIG_IGNORE_ERR[ctx.client_id]
                  or {}
                if _LSP_SIG_IGNORE_ERR[ctx.client_id][err.code] then
                  return true
                end

                _LSP_SIG_IGNORE_ERR[ctx.client_id][err.code] = true
              end
            end
          '';
        };
      };
    };
  };
}
