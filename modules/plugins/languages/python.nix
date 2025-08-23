{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames warn;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.lists) flatten;
  inherit (lib.meta) getExe getExe';
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum package bool;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.types) deprecatedSingleOrListOf;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.dag) entryBefore;

  cfg = config.vim.languages.python;

  defaultServers = ["basedpyright"];
  servers = {
    pyright = {
      enable = true;
      cmd = [(getExe' pkgs.pyright "pyright-langserver") "--stdio"];
      filetypes = ["python"];
      root_markers = [
        "pyproject.toml"
        "setup.py"
        "setup.cfg"
        "requirements.txt"
        "Pipfile"
        "pyrightconfig.json"
        ".git"
      ];
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
          vim.api.nvim_buf_create_user_command(bufnr, 'LspPyrightSetPythonPath', set_python_path, {
            desc = 'Reconfigure basedpyright with the provided python path',
            nargs = 1,
            complete = 'file',
          })
        end
      '';
    };

    basedpyright = {
      enable = true;
      cmd = [(getExe' pkgs.basedpyright "basedpyright-langserver") "--stdio"];
      filetypes = ["python"];
      root_markers = [
        "pyproject.toml"
        "setup.py"
        "setup.cfg"
        "requirements.txt"
        "Pipfile"
        "pyrightconfig.json"
        ".git"
      ];
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

          vim.api.nvim_buf_create_user_command(bufnr, 'LspPyrightSetPythonPath', set_python_path, {
            desc = 'Reconfigure basedpyright with the provided python path',
            nargs = 1,
            complete = 'file',
          })
        end
      '';
    };

    python-lsp-server = {
      enable = true;
      cmd = [(getExe pkgs.python3Packages.python-lsp-server)];
      filetypes = ["python"];
      root_markers = [
        "pyproject.toml"
        "setup.py"
        "setup.cfg"
        "requirements.txt"
        "Pipfile"
        ".git"
      ];
    };
  };

  defaultFormat = ["black"];
  formats = {
    black = {
      command = getExe pkgs.black;
    };

    isort = {
      command = getExe pkgs.isort;
    };

    # dummy option for backwards compat
    black-and-isort = {};

    ruff = {
      command = getExe pkgs.ruff;
      args = ["format" "-"];
    };

    ruff-check = {
      package = pkgs.writeShellApplication {
        name = "ruff-check";
        runtimeInputs = [pkgs.ruff];
        text = ''
          ruff check --fix --exit-zero -
        '';
      };
    };
  };

  defaultDebugger = "debugpy";
  debuggers = {
    debugpy = {
      # idk if this is the best way to install/run debugpy
      package = pkgs.python3.withPackages (ps: with ps; [debugpy]);
      dapConfig = ''
        dap.adapters.debugpy = function(cb, config)
          if config.request == 'attach' then
            ---@diagnostic disable-next-line: undefined-field
            local port = (config.connect or config).port
            ---@diagnostic disable-next-line: undefined-field
            local host = (config.connect or config).host or '127.0.0.1'
            cb({
              type = 'server',
              port = assert(port, '`connect.port` is required for a python `attach` configuration'),
              host = host,
              options = {
                source_filetype = 'python',
              },
            })
          else
            cb({
              type = 'executable',
              command = '${getExe cfg.dap.package}',
              args = { '-m', 'debugpy.adapter' },
              options = {
                source_filetype = 'python',
              },
            })
          end
        end

        dap.configurations.python = {
          {
            -- The first three options are required by nvim-dap
            type = 'debugpy'; -- the type here established the link to the adapter definition: `dap.adapters.debugpy`
            request = 'launch';
            name = "Launch file";

            -- Options below are for debugpy, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for supported options

            program = "''${file}"; -- This configuration will launch the current file if used.
            pythonPath = function()
              -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
              -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
              -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
              local cwd = vim.fn.getcwd()
              if vim.fn.executable(cwd .. '/venv/bin/python') == 1 then
                return cwd .. '/venv/bin/python'
              elseif vim.fn.executable(cwd .. '/.venv/bin/python') == 1 then
                return cwd .. '/.venv/bin/python'
              elseif vim.fn.executable("python") == 1 then
                return vim.fn.exepath("python")
              else -- WARNING cfg.dap.package probably has NO libraries other than builtins and debugpy
                return '${getExe cfg.dap.package}'
              end
            end;
          },
        }
      '';
    };
  };
in {
  options.vim.languages.python = {
    enable = mkEnableOption "Python language support";

    treesitter = {
      enable = mkEnableOption "Python treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkOption {
        description = "Python treesitter grammar to use";
        type = package;
        default = pkgs.vimPlugins.nvim-treesitter.builtGrammars.python;
      };
    };

    lsp = {
      enable = mkEnableOption "Python LSP support" // {default = config.vim.lsp.enable;};

      servers = mkOption {
        type = deprecatedSingleOrListOf "vim.language.python.lsp.servers" (enum (attrNames servers));
        default = defaultServers;
        description = "Python LSP server to use";
      };
    };

    format = {
      enable = mkEnableOption "Python formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        type = deprecatedSingleOrListOf "vim.language.python.format.type" (enum (attrNames formats));
        default = defaultFormat;
        description = "Python formatters to use";
      };
    };

    # TODO this implementation is very bare bones, I don't know enough python to implement everything
    dap = {
      enable = mkOption {
        type = bool;
        default = config.vim.languages.enableDAP;
        description = "Enable Python Debug Adapter";
      };

      debugger = mkOption {
        type = enum (attrNames debuggers);
        default = defaultDebugger;
        description = "Python debugger to use";
      };

      package = mkOption {
        type = package;
        default = debuggers.${cfg.dap.debugger}.package;
        example = literalExpression "with pkgs; python39.withPackages (ps: with ps; [debugpy])";
        description = ''
          Python debugger package.
          This is a python package with debugpy installed, see https://nixos.wiki/wiki/Python#Install_Python_Packages.
        '';
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.luaConfigRC.python-util =
        entryBefore ["lsp-servers"]
        /*
        lua
        */
        ''
          local function set_python_path(server_name, command)
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

      vim.lsp.servers =
        mapListToAttrs (n: {
          name = n;
          value = servers.${n};
        })
        cfg.lsp.servers;
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = let
        names = flatten (map (type:
          if type == "black-and-isort"
          then
            warn ''
              vim.languages.python.format.type: "black-and-isort" is deprecated,
              use `["black" "isort"]` instead.
            '' ["black" "isort"]
          else type)
        cfg.format.type);
      in {
        enable = true;
        setupOpts = {
          formatters_by_ft.python = names;
          formatters =
            mapListToAttrs (name: {
              inherit name;
              value = formats.${name};
            })
            names;
        };
      };
    })

    (mkIf cfg.dap.enable {
      vim.debugger.nvim-dap.enable = true;
      vim.debugger.nvim-dap.sources.python-debugger = debuggers.${cfg.dap.debugger}.dapConfig;
    })
  ]);
}
