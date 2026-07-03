{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.lists) flatten;
  inherit (lib) genAttrs;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum package bool listOf;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.types) deprecatedSingleOrListOf enumWithRename;
  inherit (lib.trivial) warn;

  cfg = config.vim.languages.python;

  defaultServers = ["basedpyright"];
  servers = ["pyrefly" "pyright" "basedpyright" "python-lsp-server" "ruff" "ty" "zuban"];

  defaultFormat = ["black"];
  formats = ["black" "isort" "ruff" "ruff-fix" "black-and-isort"];

  defaultDebugger = ["debugpy"];
  dapConfigurations = {
    debugpy = [
      {
        type = "debugpy";
        request = "launch";
        name = "Launch file";

        program = "\${file}";
        pythonPath = mkLuaInline ''
          function()
            -- debugpy supports launching an application with a different interpreter then the one used to launch debugpy itself.
            -- The code below looks for a `venv` or `.venv` folder in the current directly and uses the python within.
            -- You could adapt this - to for example use the `VIRTUAL_ENV` environment variable.
            local cwd = vim.fn.getcwd()
            if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
              return cwd .. "/venv/bin/python"
            elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
              return cwd .. "/.venv/bin/python"
            elseif vim.fn.executable("python") == 1 then
              return vim.fn.exepath("python")
            else -- this uses the same python package as the debugger
              return nil
            end
          end
        '';
      }
    ];
  };
  defaultDiagnosticsProvider = ["mypy"];
  diagnosticsProviders = ["mypy"];
in {
  options.vim.languages.python = {
    enable = mkEnableOption "Python language support";

    treesitter = {
      enable =
        mkEnableOption "Python treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkOption {
        description = "Python treesitter grammar to use";
        type = package;
        default = pkgs.vimPlugins.nvim-treesitter.grammarPlugins.python;
      };
    };

    lsp = {
      enable =
        mkEnableOption "Python LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };

      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Python LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "Python formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        type =
          deprecatedSingleOrListOf
          "vim.languages.python.format.type"
          (enumWithRename
            "vim.languages.python.format.type"
            formats
            {
              ruff-check = "ruff-fix";
            });
        default = defaultFormat;
        description = "Python formatters to use";
      };
    };

    # TODO this implementation is very bare bones, I don't know enough python to implement everything
    dap = {
      enable = mkOption {
        type = bool;
        default = config.vim.languages.enableDAP;
        defaultText = literalExpression "config.vim.languages.enableDAP";
        description = "Enable Python Debug Adapter";
      };

      debugger = mkOption {
        type = deprecatedSingleOrListOf "vim.languages.python.dap.debugger" (enum (attrNames dapConfigurations));
        default = defaultDebugger;
        description = "Python debugger to use";
      };
    };

    extraDiagnostics = {
      enable =
        mkEnableOption "extra Python diagnostics via nvim-lint"
        // {
          default = config.vim.languages.enableExtraDiagnostics;
          defaultText = literalExpression "config.vim.languages.enableExtraDiagnostics";
        };
      types = mkOption {
        type = listOf (enum diagnosticsProviders);
        default = defaultDiagnosticsProvider;
        description = "extra Python diagnostics providers";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["python"];
          root_markers = [
            "Pipfile"
            "pyproject.toml"
            "requirements.txt"
            "setup.cfg"
            "setup.py"
          ];
        });
      };
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
          else [type])
        cfg.format.type);
      in {
        enable = true;
        presets = genAttrs names (_: {enable = true;});
        setupOpts.formatters_by_ft.python = names;
      };
    })

    (mkIf cfg.dap.enable {
      vim.debugger.nvim-dap = {
        enable = true;
        presets = genAttrs cfg.dap.debugger (_: {enable = true;});
        configurations.python = flatten (map (name: dapConfigurations.${name}) cfg.dap.debugger);
      };
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics = {
        presets = genAttrs cfg.extraDiagnostics.types (_: {enable = true;});
        nvim-lint = {
          enable = true;
          linters_by_ft.python = cfg.extraDiagnostics.types;
        };
      };
    })
  ]);
}
