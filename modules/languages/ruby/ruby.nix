{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  #format-env = pkgs.callPackage ./format-derivation.nix {inherit pkgs;};
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
    enable = mkEnableOption "Ruby/Ruby on Rails language support";

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
        description = "Ruby/RoR LSP server package";
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
