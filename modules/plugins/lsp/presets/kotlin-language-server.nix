{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.lsp.presets.kotlin-language-server;
in {
  options.vim.lsp.presets.kotlin-language-server = {
    enable = mkLspPresetEnableOption "kotlin-language-server" "Kotlin" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.kotlin-language-server = {
      enable = true;
      cmd = [(getExe pkgs.kotlin-language-server)];
      root_markers = [
        "settings.gradle" # Gradle (multi-project)
        "settings.gradle.kts" # Gradle (multi-project)
        "build.xml" # Ant
        "pom.xml" # Maven
        "build.gradle" # Gradle
        "build.gradle.kts" # gradle
      ];
      init_options = {
        storagePath = mkLuaInline ''
          vim.fs.root(vim.fn.expand '%:p:h',
            {
              'settings.gradle', -- Gradle (multi-project)
              'settings.gradle.kts', -- Gradle (multi-project)
              'build.xml', -- Ant
              'pom.xml', -- Maven
              'build.gradle', -- Gradle
              'build.gradle.kts', -- Gradle
            }
          )
        '';
      };
    };
  };
}
