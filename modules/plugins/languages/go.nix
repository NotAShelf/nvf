{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption literalMD literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.types) bool enum package str;
  inherit (lib.nvim.types) mkGrammarOption diagnostics deprecatedSingleOrListOf mkPluginSetupOption;
  inherit (lib.nvim.dag) entryAfter;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.go;

  defaultServers = ["gopls"];
  servers = {
    gopls = {
      cmd = [(getExe pkgs.gopls)];
      filetypes = ["go" "gomod" "gosum" "gowork" "gotmpl"];
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

  defaultFormat = ["gofmt"];
  formats = {
    gofmt = {
      command = "${pkgs.go}/bin/gofmt";
    };

    gofumpt = {
      command = getExe pkgs.gofumpt;
    };

    golines = {
      command = "${pkgs.golines}/bin/golines";
    };
  };

  defaultDebugger = "delve";
  debuggers = {
    delve = {
      package = pkgs.delve;
    };
  };

  defaultDiagnosticsProvider = ["golangci-lint"];
  diagnosticsProviders = {
    golangci-lint = let
      pkg = pkgs.golangci-lint;
    in {
      package = pkg;
      config = {
        cmd = getExe pkg;
        args = [
          "run"
          "--output.json.path=stdout"
          "--issues-exit-code=0"
          "--show-stats=false"
          "--fix=false"
          "--path-mode=abs"
          # Overwrite values that could be configured and result in unwanted writes
          "--output.text.path="
          "--output.tab.path="
          "--output.html.path="
          "--output.checkstyle.path="
          "--output.code-climate.path="
          "--output.junit-xml.path="
          "--output.teamcity.path="
          "--output.sarif.path="
        ];
        parser = mkLuaInline ''
          function(output, bufnr)
            local SOURCE = "golangci-lint";

            local function display_tool_error(msg)
              return{
                {
                  bufnr = bufnr,
                  lnum = 0,
                  col = 0,
                  message = string.format("[%s] %s", SOURCE, msg),
                  severity = vim.diagnostic.severity.ERROR,
                  source = SOURCE,
                },
              }
            end

            if output == "" then
              return display_tool_error("no output provided")
            end

            local ok, decoded = pcall(vim.json.decode, output)
            if not ok then
              return display_tool_error("failed to parse JSON output")
            end

            if not decoded or not decoded.Issues then
              return display_tool_error("unexpected output format")
            end

            local severity_map = {
              error   = vim.diagnostic.severity.ERROR,
              warning = vim.diagnostic.severity.WARN,
              info    = vim.diagnostic.severity.INFO,
              hint    = vim.diagnostic.severity.HINT,
            }
            local diagnostics = {}
            for _, issue in ipairs(decoded.Issues) do
              local sev = vim.diagnostic.severity.ERROR
              if issue.Severity and issue.Severity ~= "" then
                local normalized = issue.Severity:lower()
                sev = severity_map[normalized] or vim.diagnostic.severity.ERROR
              end
              table.insert(diagnostics, {
                bufnr = bufnr,
                lnum = issue.Pos.Line - 1,
                col = issue.Pos.Column - 1,
                message = issue.Text,
                code = issue.FromLinter,
                severity = sev,
                source = SOURCE,
              })
            end
            return diagnostics
          end
        '';
      };
    };
  };
in {
  options.vim.languages.go = {
    enable = mkEnableOption "Go language support";

    treesitter = {
      enable =
        mkEnableOption "Go treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };

      goPackage = mkGrammarOption pkgs "go";
      gomodPackage = mkGrammarOption pkgs "gomod";
      gosumPackage = mkGrammarOption pkgs "gosum";
      goworkPackage = mkGrammarOption pkgs "gowork";
      gotmplPackage = mkGrammarOption pkgs "gotmpl";
    };

    lsp = {
      enable =
        mkEnableOption "Go LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };

      servers = mkOption {
        type = deprecatedSingleOrListOf "vim.language.go.lsp.servers" (enum (attrNames servers));
        default = defaultServers;
        description = "Go LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "Go formatting"
        // {
          default = !cfg.lsp.enable && config.vim.languages.enableFormat;
          defaultText = literalMD ''
            disabled if Go LSP is enabled, otherwise follows {option}`vim.languages.enableFormat`
          '';
        };

      type = mkOption {
        type = deprecatedSingleOrListOf "vim.language.go.format.type" (enum (attrNames formats));
        default = defaultFormat;
        description = "Go formatter to use";
      };
    };

    dap = {
      enable =
        mkEnableOption "Go Debug Adapter (DAP) via `nvim-dap-go"
        // {
          default = config.vim.languages.enableDAP;
          defaultText = literalExpression "config.vim.languages.enableDAP";
        };

      debugger = mkOption {
        type = enum (attrNames debuggers);
        default = defaultDebugger;
        description = "Go debugger to use";
      };

      package = mkOption {
        type = package;
        default = debuggers.${cfg.dap.debugger}.package;
        description = "Go debugger package.";
      };
    };

    extraDiagnostics = {
      enable =
        mkEnableOption "extra Go diagnostics"
        // {
          default = config.vim.languages.enableExtraDiagnostics;
          defaultText = literalExpression "config.vim.languages.enableExtraDiagnostic";
        };

      types = diagnostics {
        langDesc = "Go";
        inherit diagnosticsProviders;
        inherit defaultDiagnosticsProvider;
      };
    };

    extensions = {
      gopher-nvim = {
        enable = mkEnableOption "Minimalistic plugin for Go development";
        setupOpts = mkPluginSetupOption "gopher-nvim" {
          commands = {
            go = mkOption {
              type = str;
              default = "go";
              description = "Go binary to use";
            };

            gomodifytags = mkOption {
              type = str;
              default = getExe pkgs.gomodifytags;
              defaultText = literalExpression "getExe pkgs.gomodifytags";
              description = "gomodifytags binary to use";
            };

            gotests = mkOption {
              type = str;
              default = getExe pkgs.gotests;
              defaultText = literalExpression "getExe pkgs.gotests";
              description = "gotests binary to use";
            };

            impl = mkOption {
              type = str;
              default = getExe pkgs.impl;
              defaultText = literalExpression "getExe pkgs.impl";
              description = "impl binary to use";
            };

            iferr = mkOption {
              type = str;
              default = getExe pkgs.iferr;
              defaultText = literalExpression "getExe pkgs.iferr";
              description = "iferr binary to use";
            };

            json2go = mkOption {
              type = str;
              default = getExe inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.json2go;
              defaultText = literalExpression "getExe inputs.self.packages.$${pkgs.stdenv.hostPlatform.system}.json2go";
              description = "json2go binary to use";
            };
          };
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter = {
        enable = true;
        grammars = [
          cfg.treesitter.goPackage
          cfg.treesitter.gomodPackage
          cfg.treesitter.gosumPackage
          cfg.treesitter.goworkPackage
          cfg.treesitter.gotmplPackage
        ];
      };
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.servers =
        mapListToAttrs (name: {
          inherit name;
          value = servers.${name};
        })
        cfg.lsp.servers;
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft.go = cfg.format.type;
          formatters =
            mapListToAttrs (name: {
              inherit name;
              value = formats.${name};
            })
            cfg.format.type;
        };
      };
    })

    (mkIf cfg.dap.enable {
      vim = {
        startPlugins = ["nvim-dap-go"];
        pluginRC.nvim-dap-go = entryAfter ["nvim-dap"] ''
          require('dap-go').setup {
            delve = {
              path = '${getExe cfg.dap.package}',
            }
          }
        '';
        debugger.nvim-dap.enable = true;
      };
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics.nvim-lint = {
        enable = true;
        linters_by_ft.go = cfg.extraDiagnostics.types;
        linters =
          mkMerge (map (name: {${name} = diagnosticsProviders.${name}.config;})
            cfg.extraDiagnostics.types);
      };
    })

    (mkIf cfg.extensions.gopher-nvim.enable {
      vim.lazy.plugins.gopher-nvim = {
        package = "gopher-nvim";
        setupModule = "gopher";
        inherit (cfg.extensions.gopher-nvim) setupOpts;
        ft = ["go"];
      };
    })
  ]);
}
