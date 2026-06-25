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

  cfg = config.vim.lsp.presets.svelte-language-server;
in {
  options.vim.lsp.presets.svelte-language-server = {
    enable = mkLspPresetEnableOption "svelte-language-server" "Svelte" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.svelte-language-server = {
      enable = true;
      cmd = [(getExe pkgs.svelte-language-server) "--stdio"];
      root_dir = mkLuaInline ''
        function(bufnr, on_dir)
          local root_files = { 'package.json', '.git' }
          local fname = vim.api.nvim_buf_get_name(bufnr)
          -- Svelte LSP only supports file:// schema. https://github.com/sveltejs/language-tools/issues/2777
          if vim.uv.fs_stat(fname) ~= nil then
            on_dir(vim.fs.dirname(vim.fs.find(root_files, { path = fname, upward = true })[1]))
          end
        end
      '';
      on_attach = mkLuaInline ''
        function(client, bufnr)
          vim.api.nvim_create_autocmd('BufWritePost', {
            pattern = { '*.js', '*.ts' },
            group = vim.api.nvim_create_augroup('svelte_js_ts_file_watch', {}),
            callback = function(ctx)
              -- internal API to sync changes that have not yet been saved to the file system
              client:notify('$/onDidChangeTsOrJsFile', { uri = ctx.match })
            end,
          })

          vim.api.nvim_buf_create_user_command(bufnr, 'LspMigrateToSvelte5', function()
            client:exec_cmd({
              command = 'migrate_to_svelte_5',
              arguments = { vim.uri_from_bufnr(bufnr) },
            })
          end, { desc = 'Migrate Component to Svelte 5 Syntax' })
        end
      '';
    };
  };
}
