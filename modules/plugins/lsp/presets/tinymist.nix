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

  cfg = config.vim.lsp.presets.tinymist;
in {
  options.vim.lsp.presets.tinymist = {
    enable = mkLspPresetEnableOption "tinymist" "Tinymist" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.tinymist = {
      enable = true;
      cmd = [(getExe pkgs.tinymist)];
      root_markers = [".git"];
      on_attach = mkLuaInline ''
        function(client, bufnr)
          local function create_tinymist_command(command_name, client, bufnr)
            local export_type = command_name:match 'tinymist%.export(%w+)'
            local info_type = command_name:match 'tinymist%.(%w+)'
            if info_type and info_type:match '^get' then
              info_type = info_type:gsub('^get', 'Get')
            end
            local cmd_display = export_type or info_type
            local function run_tinymist_command()
              local arguments = { vim.api.nvim_buf_get_name(bufnr) }
              local title_str = export_type and ('Export ' .. cmd_display) or cmd_display
              local function handler(err, res)
                if err then
                  return vim.notify(err.code .. ': ' .. err.message, vim.log.levels.ERROR)
                end
                vim.notify(export_type and res or vim.inspect(res), vim.log.levels.INFO)
              end
              if vim.fn.has 'nvim-0.11' == 1 then
                return client:exec_cmd({
                  title = title_str,
                  command = command_name,
                  arguments = arguments,
                }, { bufnr = bufnr }, handler)
              else
                return vim.notify('Tinymist commands require Neovim 0.11+', vim.log.levels.WARN)
              end
            end
            local cmd_name = export_type and ('LspTinymistExport' .. cmd_display) or ('LspTinymist' .. cmd_display)
            local cmd_desc = export_type and ('Export to ' .. cmd_display) or ('Get ' .. cmd_display)
            return run_tinymist_command, cmd_name, cmd_desc
          end

          for _, command in ipairs {
            'tinymist.exportSvg',
            'tinymist.exportPng',
            'tinymist.exportPdf',
            'tinymist.exportMarkdown',
            'tinymist.exportText',
            'tinymist.exportQuery',
            'tinymist.exportAnsiHighlight',
            'tinymist.getServerInfo',
            'tinymist.getDocumentTrace',
            'tinymist.getWorkspaceLabels',
            'tinymist.getDocumentMetrics',
          } do
            local cmd_func, cmd_name, cmd_desc = create_tinymist_command(command, client, bufnr)
            vim.api.nvim_buf_create_user_command(bufnr, cmd_name, cmd_func, { nargs = 0, desc = cmd_desc })
          end
        end
      '';
    };
  };
}
