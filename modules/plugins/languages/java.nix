{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) literalExpression mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib) genAttrs;
  inherit (lib.types) listOf str;
  inherit (lib.meta) getExe;
  inherit (lib.nvim.types) mkGrammarOption mkPluginSetupOption enumWithRename;

  cfg = config.vim.languages.java;

  defaultServers = ["jdt-language-server"];
  servers = ["jdt-language-server" "jls"];
in {
  options.vim.languages.java = {
    enable = mkEnableOption "Java language support";

    treesitter = {
      enable =
        mkEnableOption "Java treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "java";
    };

    lsp = {
      enable =
        mkEnableOption "Java LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };
      servers = mkOption {
        type = listOf (enumWithRename
          "vim.languages.java.lsp.servers"
          servers
          {
            jdtls = "jdt-language-server";
          });
        default = defaultServers;
        description = "Java LSP server to use";
      };
    };

    extensions = {
      maven-nvim = {
        enable = mkEnableOption "maven integration";
        setupOpts = mkPluginSetupOption "maven-nvim" {
          mvn_executable = mkOption {
            type = str;
            default = getExe pkgs.maven;
            defaultText = literalExpression "getExe pkgs.maven";
            description = ''
              The maven executable to use.
            '';
            example = ''
              - `"mvn"`: to use the maven from the `PATH`.
              - `"./mvnw"`: to use the projects maven.
              - `"$${getExe pkgs.maven}"`: to use maven from a nix package.
            '';
          };
        };
      };
      gradle-nvim = {
        enable = mkEnableOption "gradle integration";
        setupOpts = mkPluginSetupOption "gradle-nvim" {
          gadle_executable = mkOption {
            type = str;
            default = getExe pkgs.gradle;
            defaultText = literalExpression "getExe pkgs.gradle";
            description = ''
              The gradle executable to use.
            '';
            example = ''
              - `"gradle"`: to use the gradle from the `PATH`.
              - `"$${getExe pkgs.gradle}"`: to use gradle from a nix package.
            '';
          };
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["java"];
        });
      };
    })

    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.extensions.maven-nvim.enable {
      vim = mkMerge [
        {
          startPlugins = ["nui-nvim" "plenary-nvim"];
          lazy.plugins.maven-nvim = {
            package = "maven-nvim";
            setupModule = "maven";
            setupOpts = cfg.extensions.maven-nvim.setupOpts;
          };
        }
      ];
    })

    (mkIf cfg.extensions.gradle-nvim.enable {
      vim = mkMerge [
        {
          startPlugins = ["nui-nvim" "plenary-nvim"];
          lazy.plugins.gradle-nvim = {
            package = "gradle-nvim";
            setupModule = "gradle";
            setupOpts = cfg.extensions.gradle-nvim.setupOpts;
          };
        }
      ];
    })
  ]);
}
