{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum package bool;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.types) singleOrListOf;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.dag) entryBefore;

  cfg = config.vim.languages.python;

  defaultServers = ["basedpyright"];
  servers = {
    pyright = {
      enable = true;
      cmd = [(getExe pkgs.pyright) "--stdio"];
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
            client:exec_cmd({
              command = 'pyright.organizeimports',
              arguments = { vim.uri_from_bufnr(bufnr) },
            })
          end, {
            desc = 'Organize Imports',
          })
          vim.api.nvim_buf_create_user_command(bufnr, 'LspPyrightSetPythonPath', function(opts)
            set_python_path('pyright', opts.args)
          end, {
            desc = 'Reconfigure pyright with the provided python path',
            nargs = 1,
            complete = 'file',
          })
        end
      '';
    };

    basedpyright = {
      enable = true;
      cmd = [(getExe pkgs.basedpyright) "--stdio"];
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
            client:exec_cmd({
              command = 'basedpyright.organizeimports',
              arguments = { vim.uri_from_bufnr(bufnr) },
            })
          end, {
            desc = 'Organize Imports',
          })

          vim.api.nvim_buf_create_user_command(bufnr, 'LspPyrightSetPythonPath', function(opts)
            set_python_path('basedpyright', opts.args)
          end, {
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

  defaultFormat = "black";
  formats = {
    black = {
      package = pkgs.black;
    };

    isort = {
      package = pkgs.isort;
    };

    black-and-isort = {
      package = pkgs.writeShellApplication {
        name = "black";
        runtimeInputs = [pkgs.black pkgs.isort];
        text = ''
          black --quiet - "$@" | isort --profile black -
        '';
      };
    };

    ruff = {
      package = pkgs.writeShellApplication {
        name = "ruff";
        runtimeInputs = [pkgs.ruff];
        text = ''
          ruff format -
        '';
      };
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
        type = singleOrListOf (enum (attrNames servers));
        default = defaultServers;
        description = "Python LSP server to use";
      };
    };

    format = {
      enable = mkEnableOption "Python formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        type = enum (attrNames formats);
        default = defaultFormat;
        description = "Python formatter to use";
      };

      package = mkOption {
        type = package;
        default = formats.${cfg.format.type}.package;
        description = "Python formatter package";
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
          local function set_python_path(server_name, path)
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
              client.notify('workspace/didChangeConfiguration', { settings = nil })
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
      vim.formatter.conform-nvim = {
        enable = true;
        # HACK: I'm planning to remove these soon so I just took the easiest way out
        setupOpts.formatters_by_ft.python =
          if cfg.format.type == "black-and-isort"
          then ["black"]
          else [cfg.format.type];
        setupOpts.formatters =
          if (cfg.format.type == "black-and-isort")
          then {
            black.command = "${cfg.format.package}/bin/black";
          }
          else {
            ${cfg.format.type}.command = getExe cfg.format.package;
          };
      };
    })

    (mkIf cfg.dap.enable {
      vim.debugger.nvim-dap.enable = true;
      vim.debugger.nvim-dap.sources.python-debugger = debuggers.${cfg.dap.debugger}.dapConfig;
    })
  ]);
}
