{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (lib.types) enum listOf;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.types) mkGrammarOption diagnostics;

  cfg = config.vim.languages.vue;

  defaultServers = [
    "vue_ls"
  ];
  servers = {
    vue_ls = {
      cmd = [
        (getExe pkgs.vue-language-server)
        "--stdio"
      ];
      filetypes = [
        "vue"
      ];
      root_markers = [
        "tsconfig.json"
        "jsconfig.json"
        "package.json"
        ".git"
      ];
      on_init = mkLuaInline ''
        -- forward typescript blocks to ts_ls or vtsls depending on which is available first
        function(client)
          client.handlers['tsserver/request'] = function(_, result, context)
            local ts_clients = vim.lsp.get_clients({ bufnr = context.bufnr, name = 'ts_ls' })
            local clients = {}

            vim.list_extend(clients, ts_clients)

            if #clients == 0 then
              vim.notify('Could not find `vtsls` or `ts_ls` lsp client, `vue_ls` would not work without it.', vim.log.levels.ERROR)
              return
            end
            local ts_client = clients[1]

            local param = unpack(result)
            local id, command, payload = unpack(param)
            ts_client:exec_cmd({
              title = 'vue_request_forward', -- You can give title anything as it's used to represent a command in the UI, `:h Client:exec_cmd`
              command = 'typescript.tsserverRequest',
              arguments = {
                command,
                payload,
              },
            }, { bufnr = context.bufnr }, function(_, r)
                local response = r and r.body
                -- TODO: handle error or response nil here, e.g. logging
                -- NOTE: Do NOT return if there's an error or no response, just return nil back to the vue_ls to prevent memory leak
                local response_data = { { id, response } }

                ---@diagnostic disable-next-line: param-type-mismatch
                client:notify('tsserver/response', response_data)
              end)
          end
        end
      '';
    };
  };
  defaultFormat = ["prettier"];
  formats = {
    prettier = {
      command = getExe pkgs.nodePackages.prettier;
      options.ft_parsers.vue = "vue";
    };
  };
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
          ".eslintrc.json"
          ".eslintrc.js"
          ".eslintrc.yml"
        ];
      };
    };
  };
  formatType =
    enum (attrNames formats);
in {
  _file = ./vue.nix;
  options.vim.languages.vue = {
    enable = mkEnableOption "Vue language support";

    treesitter = {
      enable = mkEnableOption "Vue treesitter" // {default = config.vim.languages.enableTreesitter;};

      vuePackage = mkGrammarOption pkgs "vue";
    };

    lsp = {
      enable = mkEnableOption "Vue LSP support" // {default = config.vim.lsp.enable;};

      servers = mkOption {
        type = listOf (enum (attrNames servers));
        default = defaultServers;
        description = "Vue LSP server to use";
      };
    };

    format = {
      enable = mkEnableOption "Vue formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        type = formatType;
        default = defaultFormat;
        description = "Vue formatter to use";
      };
    };

    extraDiagnostics = {
      enable = mkEnableOption "extra Vue diagnostics" // {default = config.vim.languages.enableExtraDiagnostics;};

      types = diagnostics {
        langDesc = "Vue";
        inherit diagnosticsProviders;
        inherit defaultDiagnosticsProvider;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.vuePackage];
    })

    (mkIf cfg.lsp.enable {
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
        setupOpts = {
          formatters_by_ft.vue = cfg.format.type;
          formatters =
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
        linters_by_ft.vue = cfg.extraDiagnostics.types;
        linters =
          mkMerge (map (name: {${name} = diagnosticsProviders.${name}.config;})
            cfg.extraDiagnostics.types);
      };
    })
  ]);
}
