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

  cfg = config.vim.lsp.presets.gopls;
in {
  options.vim.lsp.presets.gopls = {
    enable = mkLspPresetEnableOption "gopls" "Go" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.gopls = {
      enable = true;
      cmd = [(getExe pkgs.gopls)];
      root_dir = mkLuaInline ''
        function(bufnr, on_dir)
          local fname = vim.api.nvim_buf_get_name(bufnr)

          local function get_root(fname)
            if _G.nvf_gopls_mod_cache and fname:sub(1, #_G.nvf_gopls_mod_cache) == _G.nvf_gopls_mod_cache then
              local clients = vim.lsp.get_clients { name = 'gopls' }
              if #clients > 0 then
                return clients[#clients].config.root_dir
              end
            end
            return vim.fs.root(fname, 'go.work') or vim.fs.root(fname, 'go.mod') or vim.fs.root(fname, '.git')
          end

          -- see: https://github.com/neovim/nvim-lspconfig/issues/804
          if _G.nvf_gopls_mod_cache then
            on_dir(get_root(fname))
            return
          end
          local cmd = { 'go', 'env', 'GOMODCACHE' }
          local ok, err = pcall(vim.system, cmd, { text = true }, function(output)
            if output.code == 0 then
              if output.stdout then
                _G.nvf_gopls_mod_cache = vim.trim(output.stdout)
              end
              on_dir(get_root(fname))
            else
              vim.schedule(function()
                vim.notify(('[gopls] cmd failed with code %d: %s\n%s'):format(output.code, cmd, output.stderr))
              end)
            end
          end)
          if not ok then vim.notify(('[gopls] cmd failed: %s\n%s'):format(cmd, err)) end
        end
      '';
    };
  };
}
