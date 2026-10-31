{
  lib,
  pkgs,
  config,
  options,
  ...
}: let
  inherit (builtins) elem;
  inherit (lib) genAttrs;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  mkMappingOption = config.vim.lib.mkMappingOption "omnisharp-extended-lsp-nvim";
  inherit (lib.types) enum listOf;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.types) mkGrammarOption mkPluginSetupOption;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.binds) addDescriptionsToMappings;

  defaultServers = ["csharp_ls"];
  servers = ["csharp_ls" "omnisharp" "roslyn-ls"];

  defaultFormat = [];
  formats = ["csharpier" "astyle" "injected"];

  # Verbose names for clarity.
  shouldEnableExclusiveLspExtension = extension: lsp: cfg.lsp.enable && cfg.extensions.${extension}.enable && (elem lsp cfg.lsp.servers);
  mkAlertForMisuseOfExclusiveLspExtension = extension: lsp: (mkIf (cfg.lsp.enable
    && cfg.extensions.${extension}.enable) {
    assertion = elem lsp cfg.lsp.servers;
    message = "${extension} requires ${lsp} to be listed in vim.languages.csharp.lsp.servers.";
  });

  cfg = config.vim.languages.csharp;
in {
  options = {
    vim.languages.csharp = {
      enable = mkEnableOption ''
        C# language support.

        ::: {.note}
        This feature will not work if the .NET SDK is not installed.
        Both `roslyn-ls` and `csharp_ls` require the .NET SDK to function properly with Razor.
        Ensure that the .NET SDK is installed.

        Check for version compatibility for optimal performance.
        :::

        ::: {.warning}
        At the moment, only `roslyn-ls` provides full Razor support.
        `csharp_ls` is limited to `.cshtml` files.
        :::
      '';

      extensions = {
        roslyn-nvim = {
          enable = mkEnableOption ''
            Roslyn LSP plugin for Neovim that adds Razor support and works with multiple solutions

            ::: {.note}
            This feature only works for `roslyn-ls`.
            :::
          '';
          setupOpts = mkPluginSetupOption "roslyn-nvim" {
            filewatching = mkOption {
              description = ''
                "auto" | "roslyn" | "off"

                 - "auto": Does nothing for filewatching, leaving everything as default
                 - "roslyn": Turns off neovim filewatching which will make roslyn do the filewatching
                 - "off": Hack to turn off all filewatching.

                ::: {.tip}
                Set to "off" if you notice performance issues
                :::
              '';
              type = enum ["auto" "roslyn" "off"];
              default = "auto";
            };
          };
        };
        omnisharp-extended-lsp-nvim = {
          enable = mkEnableOption ''
            Extended 'textDocument/definition' handler for OmniSharp Neovim LSP

            ::: {.note}
            This feature only works for `omnisharp`.
            :::
          '';
          mappings = let
            inherit (config.vim.lsp) mappings;
          in {
            goToDefinition = mkMappingOption "Go to definition" mappings.goToDefinition;
            goToType = mkMappingOption "Go to type" mappings.goToType;
            listReferences = mkMappingOption "List references" mappings.listReferences;
            listImplementations = mkMappingOption "List implementations" mappings.listImplementations;
          };
        };
        csharpls-extended-lsp-nvim = {
          enable = mkEnableOption ''
            Extended 'textDocument/definition' handler for csharp_ls Neovim LSP

            ::: {.note}
            This feature only works for `csharp_ls`.
            :::
          '';
        };
      };

      treesitter = {
        enable =
          mkEnableOption "C# treesitter"
          // {
            default = config.vim.languages.enableTreesitter;
            defaultText = literalExpression "config.vim.languages.enableTreesitter";
          };
        csPackage = mkGrammarOption pkgs "c_sharp";
        razorPackage = mkGrammarOption pkgs "razor";
      };

      lsp = {
        enable =
          mkEnableOption "C# LSP support"
          // {
            default = config.vim.lsp.enable;
            defaultText = literalExpression "config.vim.lsp.enable";
          };
        servers = mkOption {
          description = "C# LSP server to use";
          type = listOf (enum servers);
          default = defaultServers;
        };
      };

      format = {
        enable =
          mkEnableOption "C# formatting"
          // {
            default = config.vim.languages.enableFormat;
            defaultText = literalExpression "config.vim.languages.enableFormat";
          };

        type = mkOption {
          description = "C# formatter to use";
          type = listOf (enum formats);
          default = defaultFormat;
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = with cfg.treesitter; [csPackage razorPackage];
    })

    (mkIf cfg.lsp.enable {
      vim = {
        lsp = {
          presets = genAttrs cfg.lsp.servers (_: {enable = true;});
          servers = genAttrs cfg.lsp.servers (_: {
            filetypes = ["cs" "razor" "vb"];
          });
        };
      };
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        presets = genAttrs cfg.format.type (_: {enable = true;});
        setupOpts.formatters_by_ft.cs = cfg.format.type;
      };
    })

    {
      assertions = [
        (mkAlertForMisuseOfExclusiveLspExtension "roslyn-nvim" "roslyn-ls")
        (mkAlertForMisuseOfExclusiveLspExtension "csharpls-extended-lsp-nvim" "csharp_ls")
        (mkAlertForMisuseOfExclusiveLspExtension "omnisharp-extended-lsp-nvim" "omnisharp")
      ];
    }

    (mkIf (shouldEnableExclusiveLspExtension "roslyn-nvim" "roslyn-ls") {
      vim = {
        startPlugins = ["roslyn-nvim"];
        pluginRC.roslyn-nvim = entryAnywhere "require('roslyn').setup(${toLuaObject cfg.extensions.roslyn-nvim.setupOpts})";
        lsp.servers = {
          roslyn-ls.enable = false;

          # NOTE: `roslyn-nvim` uses `roslyn` instead of `roslyn-ls`
          roslyn = {
            enable = true;
            cmd = config.vim.lsp.servers.roslyn-ls.cmd;
          };
        };
        extraPackages = with pkgs; [roslyn-ls];
      };
    })
    (mkIf (shouldEnableExclusiveLspExtension "omnisharp-extended-lsp-nvim" "omnisharp") {
      vim = {
        startPlugins = ["omnisharp-extended-lsp-nvim"];
        lsp.servers.omnisharp.on_attach = let
          mappingDefinitions = options.vim.languages.csharp.extensions.omnisharp-extended-lsp-nvim.mappings;
          mappings = addDescriptionsToMappings cfg.extensions.omnisharp-extended-lsp-nvim.mappings mappingDefinitions;
          mkBinding = binding: action:
            if binding.value != null
            then "vim.keymap.set('n', ${toLuaObject binding.value}, ${action}, {buffer=bufnr, noremap=true, silent=true, desc=${toLuaObject binding.description}})"
            else "";
        in
          mkLuaInline
          ''
            function(client, bufnr)
              ${mkBinding mappings.goToDefinition "require('omnisharp_extended').lsp_definition"}
              ${mkBinding mappings.goToType "require('omnisharp_extended').lsp_type_definition"}
              ${mkBinding mappings.listReferences "require('omnisharp_extended').lsp_references"}
              ${mkBinding mappings.listImplementations "require('omnisharp_extended').lsp_implementation"}
            end
          '';
      };
    })
    (mkIf (shouldEnableExclusiveLspExtension "csharpls-extended-lsp-nvim" "csharp_ls") {
      vim = {
        startPlugins = ["csharpls-extended-lsp-nvim"];
        lsp.servers.csharp_ls.on_attach = mkLuaInline ''
          function(client, bufnr)
            require('csharpls_extended').buf_read_cmd_bind()
          end
        '';
      };
    })
  ]);
}
