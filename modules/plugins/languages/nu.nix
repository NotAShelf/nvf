{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) str either package listOf enum;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.lua) expToLua;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (builtins) attrNames isList;

  defaultServer = "nushell";
  servers = {
    nushell = {
      package = pkgs.nushell;
      lspConfig = ''
        lspconfig.nushell.setup{
          capabilities = capabilities,
          on_attach = default_on_attach,
          cmd = ${
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ''{"${cfg.lsp.package}/bin/nu", "--no-config-file", "--lsp"}''
        }
        }
      '';
    };
  };

  # defaultFormat = "nufmt";
  # formats = {
  #   nufmt = {
  #     package = pkgs.nufmt;
  #     nullConfig = ''
  #       table.insert(
  #         ls_sources,
  #         {
  #           name = "nufmt",
  #           method = null_methods.internal.FORMATTING,
  #           filetypes = { "nu" },
  #           generator_opts = {
  #             command = "${cfg.format.package}/bin/nufmt",
  #             args = { "--stdin" },
  #             to_stdin = true
  #           },
  #           factory = null_helpers.formatter_factory
  #         }
  #       )
  #     '';
  #   };
  # };

  cfg = config.vim.languages.nu;
in {
  options.vim.languages.nu = {
    enable = mkEnableOption "Nu language support";

    treesitter = {
      enable = mkEnableOption "Nu treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "nu";
    };

    lsp = {
      enable = mkEnableOption "Nu LSP support" // {default = config.vim.languages.enableLSP;};
      server = mkOption {
        description = "Nu LSP server to use";
        type = str;
        default = defaultServer;
      };

      package = mkOption {
        type = either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
        example = ''[(lib.getExe pkgs.nushell) "--lsp"]'';
        description = "Nu LSP server package, or the command to run as a list of strings"; 
      };
    };

    # format = {
    #   enable = mkEnableOption "Nu formatting" // {default = config.vim.languages.enableFormat;};
    #
    #   type = mkOption {
    #     description = "Nu formatter to use";
    #     type = enum (attrNames formats);
    #     default = defaultFormat;
    #   };
    #   package = mkOption {
    #     description = "Nu formatter package";
    #     type = package;
    #     default = formats.${cfg.format.type}.package;
    #   };
    # };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.nu-lsp = servers.${cfg.lsp.server}.lspConfig;
    })

    # (mkIf cfg.format.enable {
    #   vim.lsp.null-ls.enable = true;
    #   vim.lsp.null-ls.sources.nu-format = formats.${cfg.format.type}.nullConfig;
    # })
  ]);
}
