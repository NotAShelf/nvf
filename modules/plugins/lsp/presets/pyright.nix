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

  cfg = config.vim.lsp.presets.pyright;
in {
  options.vim.lsp.presets.pyright = {
    enable = mkLspPresetEnableOption "pyright" "Pyright" [];
  };

  config = mkIf cfg.enable {
    vim = {
      lsp.servers.pyright = {
        enable = true;
        cmd = [(getExe' pkgs.pyright "pyright-langserver") "--stdio"];
        root_markers = [".git" "pyrightconfig.json"];
        settings = {
          python = {
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
                command = 'pyright.organizeimports',
                arguments = { vim.uri_from_bufnr(bufnr) },
              }

              -- Using client.request() directly because "pyright.organizeimports" is private
              -- (not advertised via capabilities), which client:exec_cmd() refuses to call.
              -- https://github.com/neovim/neovim/blob/c333d64663d3b6e0dd9aa440e433d346af4a3d81/runtime/lua/vim/lsp/client.lua#L1024-L1030
              client.request('workspace/executeCommand', params, nil, bufnr)
            end, {
              desc = 'Organize Imports',
            })
            vim.api.nvim_buf_create_user_command(bufnr, 'LspPyrightSetPythonPath', pyright_set_python_path, {
              desc = 'Reconfigure pyright with the provided python path',
              nargs = 1,
              complete = 'file',
            })
          end
        '';
      };
      luaConfigRC.pyright-util = entryBefore ["lsp-servers"] ''
        local function pyright_set_python_path(server_name, command)
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
