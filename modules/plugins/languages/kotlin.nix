{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe' getExe;
  inherit (builtins) attrNames;
  inherit (lib.types) enum listOf;
  inherit (lib.nvim.types) mkGrammarOption diagnostics;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.kotlin;

  defaultServers = ["kotlin-language-server"];
  servers = {
    kotlin-language-server = {
      enable = true;
      cmd = [(getExe' pkgs.kotlin-language-server "kotlin-language-server")];
      filetypes = ["kotlin"];
      root_markers = [
        "settings.gradle" # Gradle (multi-project)
        "settings.gradle.kts" # Gradle (multi-project)
        "build.xml" # Ant
        "pom.xml" # Maven
        "build.gradle" # Gradle
        "build.gradle.kts" # gradle
      ];
      init_options = {
        storagePath = mkLuaInline "
        vim.fs.root(vim.fn.expand '%:p:h',
          {
            'settings.gradle', -- Gradle (multi-project)
            'settings.gradle.kts', -- Gradle (multi-project)
            'build.xml', -- Ant
            'pom.xml', -- Maven
            'build.gradle', -- Gradle
            'build.gradle.kts', -- Gradle
          }
        )";
      };
    };
  };

  defaultDiagnosticsProvider = ["ktlint"];
  diagnosticsProviders = {
    ktlint = {
      package = pkgs.ktlint;
    };
  };
in {
  options.vim.languages.kotlin = {
    enable = mkEnableOption "Kotlin/HCL support";

    treesitter = {
      enable = mkEnableOption "Kotlin treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "kotlin";
    };

    lsp = {
      enable = mkEnableOption "Kotlin LSP support" // {default = config.vim.lsp.enable;};
      servers = mkOption {
        type = listOf (enum (attrNames servers));
        default = defaultServers;
        description = "Kotlin LSP server to use";
      };
    };

    extraDiagnostics = {
      enable = mkEnableOption "extra Kotlin diagnostics" // {default = config.vim.languages.enableExtraDiagnostics;};

      types = diagnostics {
        langDesc = "Kotlin";
        inherit diagnosticsProviders;
        inherit defaultDiagnosticsProvider;
      };
    };
  };
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.diagnostics.nvim-lint = {
        enable = true;
        linters_by_ft.kotlin = cfg.extraDiagnostics.types;
        linters = mkMerge (map (name: {
            ${name}.cmd = getExe diagnosticsProviders.${name}.package;
          })
          cfg.extraDiagnostics.types);
      };
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.servers =
        mapListToAttrs (n: {
          name = n;
          value = servers.${n};
        })
        cfg.lsp.servers;
    })
  ]);
}
