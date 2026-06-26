{
  config,
  lib,
  pkgs,
  options,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) literalExpression mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (lib.types) enum listOf nullOr str bool;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.types) mkGrammarOption mkPluginSetupOption;
  inherit (config.vim.lib) mkMappingOption;
  inherit (lib.nvim.binds) mkKeymap;

  cfg = config.vim.languages.http;

  defaultFormat = ["kulala-fmt"];
  formats = {
    kulala-fmt = {
      command = getExe pkgs.kulala-fmt;
    };
  };
in {
  options.vim.languages.http = {
    enable = mkEnableOption "HTTP request file support";

    treesitter = {
      enable =
        mkEnableOption "HTTP request file treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "http";
    };

    format = {
      enable =
        mkEnableOption "HTTP request file formatting"
        // {
          default = config.vim.languages.enableFormat;
          defaultText = literalExpression "config.vim.languages.enableFormat";
        };

      type = mkOption {
        description = "HTTP request file formatter to use";
        type = listOf (enum (attrNames formats));
        default = defaultFormat;
      };
    };

    extensions = {
      kulala-nvim = {
        enable = mkEnableOption ''
          A fully-featured ⚡️ HTTP/GraphQL/gRPC/Websocket-client 🐼 interface 🖥️ for Neovim ❤️,
          that supports the Jetbrains .http spec (with full scripting support).
        '';
        setupOpts = mkPluginSetupOption "kulala.nvim" {
          kulala_core = {
            path = mkOption {
              type = nullOr str;
              # TODO: set default, when kulala-core is package in nixpkgs some day
              default = null;
              defaultText = literalExpression "getExe pkgs.kulala-fmt";
              description = ''
                Optional path to the [kulala-core executable](https://github.com/mistweaverco/kulala-core).
                When set, this path is used exclusively.
                When null (default), auto-download and
                use kulala-core from GitHub releases based on the user's OS and architecture.
              '';
            };
            download_tool = mkOption {
              type = str;
              default = "${pkgs.curlMinimal}/bin/curl";
              defaultText = literalExpression "$${pkgs.curlMinimal}/bin/curl";
              description = "`curl` or `wget` or full path to `curl` or `wget` executable.";
            };
          };
          lsp = {
            enable = mkOption {
              type = bool;
              default = true;
              description = "Enable plugin managed LSP";
            };
          };
        };

        mappings = {
          openScratchpad = mkMappingOption "Open scratchpad" "<leader>Rb";
          sendRequest = mkMappingOption "Send request" "<leader>Rs";
          sendAllRequests = mkMappingOption "Send all requests" "<leader>Ra";
          replayRequest = mkMappingOption "Replay the last request" "<leader>Rr";
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter = {
        enable = true;
        grammars = [cfg.treesitter.package];
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft.http = cfg.format.type;
          formatters =
            mapListToAttrs (name: {
              inherit name;
              value = formats.${name};
            })
            cfg.format.type;
        };
      };
    })

    (mkIf cfg.extensions.kulala-nvim.enable {
      vim.lazy.plugins.kulala-nvim = let
        extCfg = cfg.extensions.kulala-nvim;
        extOpts = options.vim.languages.http.extensions.kulala-nvim;
      in {
        package = "kulala-nvim";
        ft = ["http" "rest"];
        event = ["SessionLoadPost" "VimLeavePre"];
        setupModule = "kulala";
        setupOpts = {treesitter.enable = false;} // cfg.extensions.kulala-nvim.setupOpts;

        keys = let
          mkAction = action: "function() require('kulala').${action}() end";
        in [
          (mkKeymap ["n"] extCfg.mappings.openScratchpad (mkAction "scratchpad") {
            lua = true;
            desc = extOpts.mappings.openScratchpad.description;
          })
          (mkKeymap ["n" "v"] extCfg.mappings.sendRequest (mkAction "run") {
            lua = true;
            ft = ["http" "rest"];
            desc = extOpts.mappings.sendRequest.description;
          })
          (mkKeymap ["n" "v"] extCfg.mappings.sendAllRequests (mkAction "run_all") {
            lua = true;
            ft = ["http" "rest"];
            desc = extOpts.mappings.sendAllRequests.description;
          })
          (mkKeymap ["n" "v"] extCfg.mappings.replayRequest (mkAction "replay") {
            lua = true;
            ft = ["http" "rest"];
            desc = extOpts.mappings.replayRequest.description;
          })
        ];
      };
    })
  ]);
}
