{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) package;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.lists) isList;
  inherit (lib.nvim.lua) expToLua;

  cfg = config.vim.languages.kotlin;

  # Creating a version of the LSP with access to the kotlin binary.
  # This is necessary for the LSP to load the standard library
  kotlinLspWithRuntime = pkgs.symlinkJoin {
    name = "kotlin-language-server-with-runtime";
    paths = [
      pkgs.kotlin-language-server
      pkgs.kotlin
    ];
    buildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/kotlin-language-server \
        --prefix PATH : ${pkgs.lib.makeBinPath [pkgs.kotlin]}
    '';
  };
in {
  options.vim.languages.kotlin = {
    enable = mkEnableOption "kotlin/HCL support";

    treesitter = {
      enable = mkEnableOption "kotlin treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "kotlin";
    };

    lsp = {
      enable = mkEnableOption "kotlin LSP support (kotlin_language_server)" // {default = config.vim.languages.enableLSP;};

      package = mkOption {
        description = "kotlin_language_server package with Kotlin runtime";
        type = package;
        default = kotlinLspWithRuntime;
      };
    };
  };
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.kotlin_language_server = ''
        lspconfig.kotlin_language_server.setup {
          capabilities = capabilities,
          root_dir = lspconfig.util.root_pattern("main.kt", ".git"),
          on_attach=default_on_attach,
          init_options = {
          -- speeds up the startup time for the LSP
            storagePath = "vim.fn.stdpath('state') .. '/kotlin'",
          },
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{"${cfg.lsp.package}/bin/kotlin-language-server"}''
        },
        }
      '';
    })
  ]);
}
