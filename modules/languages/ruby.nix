{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.languages.ruby;

  defaultServer = "rubyserver";
  servers = {
    rubyserver = {
      package = pkgs.rubyPackages_3_2.solargraph;
      lspConfig = ''
        lspconfig.rubyserver.setup {
          capabilities = capabilities;
          on_attach = attach_keymaps,
          cmd = { "${pkgs.bundler}/bin/bundle exec solargraph", "stdio" }
        }
      '';
    };
  };

  # TODO: specify packages
  defaultFormat = "rubocop";
  formats = {
    rubocop = {
      package = pkgs.rubocop;
      nullConfig = ''

        local conditional = function(fn)
          local utils = require("null-ls.utils").make_conditional_utils()
          return fn(utils)
        end

        table.insert(
          ls_sources,
                     null_ls.builtins.formatting.rubocop.with({
                         command = "${pkgs.bundler}/bin/bundle",
                      args = vim.list_extend(
                          { "exec", "rubocop", "-a" },
                          null_ls.builtins.formatting.rubocop._opts.args
                        ),
                     })


          -- conditional(function(utils)
          --   return utils.root_has_file("Gemfile")
          --           and null_ls.builtins.formatting.rubocop.with({
          --               command = "${pkgs.bundler}",
           --            args = vim.list_extend(
          --                { "exec", "rubocop" },
          --                nls.builtins.formatting.rubocop._opts.args
          --              ),
          --           })
          --           or null_ls.builtins.formatting.rubocop.with({
          --             command = "${cfg.format.package}/bin/rubocop",
         --          })
          -- end)
        )
      '';
    };
  };
  # TODO: specify packages
  defaultDiagnostics = ["rubocop"];
  diagnostics = {
    rubocop = {
      package = pkgs.rubyPackages_3_2.rubocop;
      nullConfig = pkg: ''
        table.insert(
          ls_sources,
          null_ls.builtins.diagnostics.rubocop.with({
            command = "${lib.getExe pkg}",
          })
        )
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

    format = {
      enable = mkEnableOption "Enable Ruby/RoR formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        description = "Ruby/RoR formatter to use";
        type = with types; enum (attrNames formats);
        default = defaultFormat;
      };

      package = mkOption {
        description = "Ruby/RoR formatter package";
        type = types.package;
        default = formats.${cfg.format.type}.package;
      };
    };

    extraDiagnostics = {
      enable = mkEnableOption "Enable extra Ruby/RoR diagnostics" // {default = config.vim.languages.enableExtraDiagnostics;};

      types = lib.nvim.types.diagnostics {
        langDesc = "Ruby/RoR";
        inherit diagnostics;
        inherit defaultDiagnostics;
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

    (mkIf cfg.format.enable {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources.ruby-format = formats.${cfg.format.type}.nullConfig;
    })

    (mkIf cfg.extraDiagnostics.enable {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources = lib.nvim.languages.diagnosticsToLua {
        lang = "ruby";
        config = cfg.extraDiagnostics.types;
        inherit diagnostics;
      };
    })
  ]);
}
