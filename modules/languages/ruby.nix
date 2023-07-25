{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.languages.ruby;

  defaultServer = "rubocop";
  servers = {
    solargraph = {
      package = pkgs.ruby_3_2;

      lspConfig = ''
        lspconfig.solargraph.setup {
          on_attach = attach_keymaps,
          cmd = { "${cfg.lsp.package}/bin/bundle", "exec", "solargraph", "stdio" }
        }
      '';
    };

    rubocop = {
      package = pkgs.ruby_3_2;

      lspConfig = ''
        lspconfig.rubocop.setup {
          on_attach = attach_keymaps,
          cmd = { "${cfg.lsp.package}/bin/bundle", "exec", "rubocop", "--lsp" },
        }
      '';
    };
  };
in {
  options.vim.languages.ruby = {
    enable = mkEnableOption ''
      Ruby/Ruby on Rails language support.

      CAUTION: Ruby relies on your system for your project's dependencies, and it works the other way around too for code quality checking softwares.

      What that means is you have to have:
      * The language server(rubocop or solargraph) specified in your Gemfile
      * Your project's gems installed on your system

      You can either install them declaratively, or use a `shell.nix` along with a bundix setup to make your dependenicies available (special mention to libv8-node, which you cannot install via a gemset.nix due to it downloading nodejs with wget...)
    '';

    treesitter = {
      enable = mkEnableOption "Enable Ruby treesitter" // {default = config.vim.languages.enableTreesitter;};
      rubyPackage = nvim.types.mkGrammarOption pkgs "ruby";
    };

    lsp = {
      enable = mkEnableOption "Enable Ruby/Ruby on Rails LSP support" // {default = config.vim.languages.enableLSP;};

      server = mkOption {
        description = "Ruby/RoR LSP server to use";
        type = with types; enum (attrNames servers);
        default = defaultServer;
      };

      package = mkOption {
        description = "Ruby package to use for ruby LSP (important if you have a specific version of ruby)";
        type = types.package;
        default = servers.${cfg.lsp.server}.package;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.rubyPackage];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.ruby-lsp = servers.${cfg.lsp.server}.lspConfig;
    })
  ]);
}
