{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.lists) isList;
  inherit (lib.meta) getExe;
  inherit (lib.types) enum either listOf package str bool;
  inherit (lib.nvim.lua) expToLua toLuaObject;
  inherit (lib.nvim.types) mkGrammarOption diagnostics mkPluginSetupOption;
  inherit (lib.nvim.languages) diagnosticsToLua;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.languages.ts;

  defaultServer = "ts_ls";
  servers = {
    ts_ls = {
      package = pkgs.typescript-language-server;
      lspConfig = ''
        lspconfig.ts_ls.setup {
          capabilities = capabilities,
          on_attach = function(client, bufnr)
            attach_keymaps(client, bufnr);
            client.server_capabilities.documentFormattingProvider = false;
          end,
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{"${cfg.lsp.package}/bin/typescript-language-server", "--stdio"}''
        }
        }
      '';
    };

    denols = {
      package = pkgs.deno;
      lspConfig = ''
        vim.g.markdown_fenced_languages = { "ts=typescript" }
        lspconfig.denols.setup {
          capabilities = capabilities;
          on_attach = attach_keymaps,
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{"${cfg.lsp.package}/bin/deno", "lsp"}''
        }
        }
      '';
    };

    # Here for backwards compatibility. Still consider tsserver a valid
    # configuration in the enum, but assert if it's set to *properly*
    # redirect the user to the correct server.
    tsserver = {
      package = pkgs.typescript-language-server;
      lspConfig = ''
        lspconfig.ts_ls.setup {
          capabilities = capabilities;
          on_attach = attach_keymaps,
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{"${cfg.lsp.package}/bin/typescript-language-server", "--stdio"}''
        }
        }
      '';
    };
  };

  # TODO: specify packages
  defaultFormat = "prettier";
  formats = {
    prettier = {
      package = pkgs.nodePackages.prettier;
      nullConfig = ''
        table.insert(
          ls_sources,
          null_ls.builtins.formatting.prettier.with({
            command = "${cfg.format.package}/bin/prettier",
            filetypes = { "typescript", "javascript" },
          })
        )
      '';
    };

    prettierd = {
      package = pkgs.prettierd;
      nullConfig = ''
        table.insert(
          ls_sources,
          null_ls.builtins.formatting.prettier.with({
            command = "${cfg.format.package}/bin/prettierd",
          })
        )
      '';
    };

    biome = {
      package = pkgs.biome;
      nullConfig = ''
        table.insert(
          ls_sources,
          null_ls.builtins.formatting.biome.with({
            command = "${cfg.format.package}/bin/biome",
          })
        )
      '';
    };
  };

  # TODO: specify packages
  defaultDiagnosticsProvider = ["eslint_d"];
  diagnosticsProviders = {
    eslint_d = {
      package = pkgs.eslint_d;
      nullConfig = pkg: ''
        table.insert(
          ls_sources,
          null_ls.builtins.diagnostics.eslint_d.with({
            command = "${getExe pkg}",
            condition = function(utils)
              return utils.root_has_file({
                "eslint.config.js",
                "eslint.config.mjs",
                ".eslintrc",
                ".eslintrc.json",
                ".eslintrc.js",
                ".eslintrc.yml",
              })
            end,
          })
        )
      '';
    };
  };
in {
  _file = ./ts.nix;
  options.vim.languages.ts = {
    enable = mkEnableOption "Typescript/Javascript language support";

    treesitter = {
      enable = mkEnableOption "Typescript/Javascript treesitter" // {default = config.vim.languages.enableTreesitter;};
      tsPackage = mkGrammarOption pkgs "tsx";
      jsPackage = mkGrammarOption pkgs "javascript";
    };

    lsp = {
      enable = mkEnableOption "Typescript/Javascript LSP support" // {default = config.vim.languages.enableLSP;};

      server = mkOption {
        description = "Typescript/Javascript LSP server to use";
        type = enum (attrNames servers);
        default = defaultServer;
      };

      package = mkOption {
        description = "Typescript/Javascript LSP server package, or the command to run as a list of strings";
        example = ''[lib.getExe pkgs.jdt-language-server "-data" "~/.cache/jdtls/workspace"]'';
        type = either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
      };
    };

    format = {
      enable = mkEnableOption "Typescript/Javascript formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        description = "Typescript/Javascript formatter to use";
        type = enum (attrNames formats);
        default = defaultFormat;
      };

      package = mkOption {
        description = "Typescript/Javascript formatter package";
        type = package;
        default = formats.${cfg.format.type}.package;
      };
    };

    extraDiagnostics = {
      enable = mkEnableOption "extra Typescript/Javascript diagnostics" // {default = config.vim.languages.enableExtraDiagnostics;};

      types = diagnostics {
        langDesc = "Typescript/Javascript";
        inherit diagnosticsProviders;
        inherit defaultDiagnosticsProvider;
      };
    };

    extensions = {
      ts-error-translator = {
        enable = mkEnableOption ''
          [ts-error-translator.nvim]: https://github.com/dmmulroy/ts-error-translator.nvim

          Typescript error translation with [ts-error-translator.nvim]

        '';

        setupOpts = mkPluginSetupOption "ts-error-translator" {
          # This is the default configuration behaviour.
          auto_override_publish_diagnostics = mkOption {
            description = "Automatically override the publish_diagnostics handler";
            type = bool;
            default = true;
          };
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.tsPackage cfg.treesitter.jsPackage];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.ts-lsp = servers.${cfg.lsp.server}.lspConfig;
    })

    (mkIf cfg.format.enable {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources.ts-format = formats.${cfg.format.type}.nullConfig;
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources = diagnosticsToLua {
        lang = "ts";
        config = cfg.extraDiagnostics.types;
        inherit diagnosticsProviders;
      };
    })

    # Extensions
    (mkIf cfg.extensions."ts-error-translator".enable {
      vim.startPlugins = ["ts-error-translator-nvim"];
      vim.pluginRC.ts-error-translator = entryAnywhere ''
        require("ts-error-translator").setup(${toLuaObject cfg.extensions.ts-error-translator.setupOpts})
      '';
    })

    # Warn the user if they have set the default server name to tsserver to match upstream (us)
    # The name "tsserver" has been deprecated in lspconfig, and now should be called ts_ls. This
    # is a purely cosmetic change, but emits a warning if not accounted for.
    {
      assertions = [
        {
          assertion = cfg.lsp.enable -> cfg.lsp.server != "tsserver";
          message = ''
            As of a recent lspconfig update, the `tsserver` configuration has been renamed
            to `ts_ls` to match upstream behaviour of `lspconfig`, and the name `tsserver`
            is no longer considered valid by nvf. Please set `vim.languages.ts.lsp.server`
            to `"ts_ls"` instead of to `${cfg.lsp.server}`

            Please see <https://github.com/neovim/nvim-lspconfig/pull/3232> for more details
            about this change.
          '';
        }
      ];
    }
  ]);
}
