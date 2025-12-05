{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames elem;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (lib.types) enum package bool;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.types) mkGrammarOption diagnostics mkPluginSetupOption deprecatedSingleOrListOf;
  inherit (lib.nvim.dag) entryAnywhere entryBefore;

  cfg = config.vim.languages.ts;

  defaultServers = ["ts_ls"];
  servers = let
    ts_ls = {
      cmd = [(getExe pkgs.typescript-language-server) "--stdio"];
      init_options = {hostInfo = "neovim";};
      filetypes = [
        "javascript"
        "javascriptreact"
        "javascript.jsx"
        "typescript"
        "typescriptreact"
        "typescript.tsx"
      ];
      root_markers = ["tsconfig.json" "jsconfig.json" "package.json" ".git"];
      handlers = {
        # handle rename request for certain code actions like extracting functions / types
        "_typescript.rename" = mkLuaInline ''
          function(_, result, ctx)
            local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
            vim.lsp.util.show_document({
              uri = result.textDocument.uri,
              range = {
                start = result.position,
                ['end'] = result.position,
              },
            }, client.offset_encoding)
            vim.lsp.buf.rename()
            return vim.NIL
          end
        '';
      };
      on_attach = mkLuaInline ''
        function(client, bufnr)
          -- ts_ls provides `source.*` code actions that apply to the whole file. These only appear in
          -- `vim.lsp.buf.code_action()` if specified in `context.only`.
          vim.api.nvim_buf_create_user_command(0, 'LspTypescriptSourceAction', function()
            local source_actions = vim.tbl_filter(function(action)
              return vim.startswith(action, 'source.')
            end, client.server_capabilities.codeActionProvider.codeActionKinds)

            vim.lsp.buf.code_action({
              context = {
                only = source_actions,
              },
            })
          end, {})
        end
      '';
    };
  in {
    inherit ts_ls;
    # Here for backwards compatibility. Still consider tsserver a valid
    # configuration in the enum, but assert if it's set to *properly*
    # redirect the user to the correct server.
    tsserver = ts_ls;

    denols = {
      cmd = [(getExe pkgs.deno) "lsp"];
      cmd_env = {NO_COLOR = true;};
      filetypes = [
        "javascript"
        "javascriptreact"
        "javascript.jsx"
        "typescript"
        "typescriptreact"
        "typescript.tsx"
      ];
      root_markers = ["deno.json" "deno.jsonc" ".git"];
      settings = {
        deno = {
          enable = true;
          suggest = {
            imports = {
              hosts = {
                "https://deno.land" = true;
              };
            };
          };
        };
      };
      handlers = {
        "textDocument/definition" = mkLuaInline "nvf_denols_handler";
        "textDocument/typeDefinition" = mkLuaInline "nvf_denols_handler";
        "textDocument/references" = mkLuaInline "nvf_denols_handler";
      };
      on_attach = mkLuaInline ''
        function(client, bufnr)
          vim.api.nvim_buf_create_user_command(0, 'LspDenolsCache', function()
            client:exec_cmd({
              command = 'deno.cache',
              arguments = { {}, vim.uri_from_bufnr(bufnr) },
            }, { bufnr = bufnr }, function(err, _result, ctx)
              if err then
                local uri = ctx.params.arguments[2]
                vim.api.nvim_err_writeln('cache command failed for ' .. vim.uri_to_fname(uri))
              end
            end)
          end, {
            desc = 'Cache a module and all of its dependencies.',
          })
        end
      '';
    };
  };

  denols_handlers = ''
    local function nvf_denols_virtual_text_document_handler(uri, res, client)
      if not res then
        return nil
      end

      local lines = vim.split(res.result, '\n')
      local bufnr = vim.uri_to_bufnr(uri)

      local current_buf = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      if #current_buf ~= 0 then
        return nil
      end

      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
      vim.api.nvim_set_option_value('readonly', true, { buf = bufnr })
      vim.api.nvim_set_option_value('modified', false, { buf = bufnr })
      vim.api.nvim_set_option_value('modifiable', false, { buf = bufnr })
      vim.lsp.buf_attach_client(bufnr, client.id)
    end

    local function nvf_denols_virtual_text_document(uri, client)
      local params = {
        textDocument = {
          uri = uri,
        },
      }
      local result = client.request_sync('deno/virtualTextDocument', params)
      nvf_denols_virtual_text_document_handler(uri, result, client)
    end

    local function nvf_denols_handler(err, result, ctx, config)
      if not result or vim.tbl_isempty(result) then
        return nil
      end

      local client = vim.lsp.get_client_by_id(ctx.client_id)
      for _, res in pairs(result) do
        local uri = res.uri or res.targetUri
        if uri:match '^deno:' then
          nvf_denols_virtual_text_document(uri, client)
          res['uri'] = uri
          res['targetUri'] = uri
        end
      end

      vim.lsp.handlers[ctx.method](err, result, ctx, config)
    end
  '';

  # TODO: specify packages
  defaultFormat = ["prettier"];
  formats = {
    prettier = {
      command = getExe pkgs.prettier;
    };

    prettierd = {
      command = getExe pkgs.prettierd;
    };

    biome = {
      command = getExe pkgs.biome;
    };
  };

  # TODO: specify packages
  defaultDiagnosticsProvider = ["eslint_d"];
  diagnosticsProviders = {
    eslint_d = let
      pkg = pkgs.eslint_d;
    in {
      package = pkg;
      config = {
        cmd = getExe pkg;
        required_files = [
          "eslint.config.js"
          "eslint.config.mjs"
          ".eslintrc"
          ".eslintrc.cjs"
          ".eslintrc.json"
          ".eslintrc.js"
          ".eslintrc.yml"
        ];
      };
    };
  };
in {
  _file = ./ts.nix;
  options.vim.languages.ts = {
    enable = mkEnableOption "Typescript/Javascript language support";

    treesitter = {
      enable = mkEnableOption "Typescript/Javascript treesitter" // {default = config.vim.languages.enableTreesitter;};
      tsPackage = mkGrammarOption pkgs "typescript";
      tsxPackage = mkGrammarOption pkgs "tsx";
      jsPackage = mkGrammarOption pkgs "javascript";
    };

    lsp = {
      enable = mkEnableOption "Typescript/Javascript LSP support" // {default = config.vim.lsp.enable;};

      servers = mkOption {
        type = deprecatedSingleOrListOf "vim.language.ts.lsp.servers" (enum (attrNames servers));
        default = defaultServers;
        description = "Typescript/Javascript LSP server to use";
      };
    };

    format = {
      enable = mkEnableOption "Typescript/Javascript formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        description = "Typescript/Javascript formatter to use";
        type = deprecatedSingleOrListOf "vim.language.ts.format.type" (enum (attrNames formats));
        default = defaultFormat;
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
      vim.treesitter.grammars = [
        cfg.treesitter.tsPackage
        cfg.treesitter.tsxPackage
        cfg.treesitter.jsPackage
      ];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.servers =
        mapListToAttrs (name: {
          inherit name;
          value = servers.${name};
        })
        cfg.lsp.servers;
    })

    (mkIf (cfg.lsp.enable && elem "denols" cfg.lsp.servers) {
      vim.globals.markdown_fenced_languages = ["ts=typescript"];
      vim.luaConfigRC.denols_handlers = entryBefore ["lsp-servers"] denols_handlers;
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft = {
            typescript = cfg.format.type;
            javascript = cfg.format.type;
            # .tsx/.jsx files
            typescriptreact = cfg.format.type;
          };
          setupOpts.formatters =
            mapListToAttrs (name: {
              inherit name;
              value = formats.${name};
            })
            cfg.format.type;
        };
      };
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics.nvim-lint = {
        enable = true;
        linters_by_ft.typescript = cfg.extraDiagnostics.types;
        linters_by_ft.typescriptreact = cfg.extraDiagnostics.types;

        linters =
          mkMerge (map (name: {${name} = diagnosticsProviders.${name}.config;})
            cfg.extraDiagnostics.types);
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
          assertion = cfg.lsp.enable -> !(elem "tsserver" cfg.lsp.servers);
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
