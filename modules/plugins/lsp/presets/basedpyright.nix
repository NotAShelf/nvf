{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe';
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.dag) entryBefore;

  cfg = config.vim.lsp.presets.basedpyright;
in {
  options.vim.lsp.presets.basedpyright = {
    enable = mkLspPresetEnableOption "basedpyright" "Based Pyright" [];
  };

  config = mkIf cfg.enable {
    vim = {
      lsp.servers.basedpyright = {
        enable = true;
        cmd = [(getExe' pkgs.basedpyright "basedpyright-langserver") "--stdio"];
        root_markers = [".git" "pyrightconfig.json"];
        settings = {
          basedpyright = {
            analysis = {
              autoSearchPaths = true;
              useLibraryCodeForTypes = true;
              diagnosticMode = "openFilesOnly";
            };
          };
        };
        on_attach = mkLuaInline ''
          function(client, bufnr)
            vim.api.nvim_buf_create_user_command(bufnr, 'LspPyrightOrganizeImports', function()
              local params = {
                command = 'basedpyright.organizeimports',
                arguments = { vim.uri_from_bufnr(bufnr) },
              }

              -- Using client.request() directly because "basedpyright.organizeimports" is private
              -- (not advertised via capabilities), which client:exec_cmd() refuses to call.
              -- https://github.com/neovim/neovim/blob/c333d64663d3b6e0dd9aa440e433d346af4a3d81/runtime/lua/vim/lsp/client.lua#L1024-L1030
              client.request('workspace/executeCommand', params, nil, bufnr)
            end, {
              desc = 'Organize Imports',
            })

            vim.api.nvim_buf_create_user_command(bufnr, 'LspPyrightSetPythonPath', basedpyright_set_python_path, {
              desc = 'Reconfigure basedpyright with the provided python path',
              nargs = 1,
              complete = 'file',
            })
          end
        '';
      };
      luaConfigRC.basedpyright-util = entryBefore ["lsp-servers"] ''
        local function basedpyright_set_python_path(server_name, command)
          local path = command.args
          local clients = vim.lsp.get_clients {
            bufnr = vim.api.nvim_get_current_buf(),
            name = server_name,
          }
          for _, client in ipairs(clients) do
            if client.settings then
              client.settings.python = vim.tbl_deep_extend('force', client.settings.python or {}, { pythonPath = path })
            else
              client.config.settings = vim.tbl_deep_extend('force', client.config.settings, { python = { pythonPath = path } })
            end
            client:notify('workspace/didChangeConfiguration', { settings = nil })
          end
        end
      '';
    };
  };
}
