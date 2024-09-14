{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption mkPackageOption;
  inherit (lib.types) str either package listOf enum;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.lua) expToLua;
  inherit (pkgs) fetchFromGitHub;
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

  # FIX: uncomment formatting parts, once https://github.com/NixOS/nixpkgs/pull/341647 makes it into nixos-unstable
  # defaultFormat = "nufmt";
  # formats = {
  #   nufmt = {
  #     package = pkgs.nufmt.overrideAttrs {
  #       src = fetchFromGitHub {
  #         owner = "nushell";
  #         repo = "nufmt";
  #         rev = "63549df4406216cce7e744576b1ee8fcaba9a30a";
  #         hash = "sha256-Y7LvsCuirhYPjuQSF0w7me8vYrV39i4OhVvyI3XskpE=";
  #       };
  #     };
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
      package = mkOption {
        description = "The Nu treesitter package to use.";
        type = package;
        default = pkgs.tree-sitter.buildGrammar {
          language = "nu";
          version = "0.0.0+rev=0bb9a60";
          src = fetchFromGitHub {
            owner = "nushell";
            repo = "tree-sitter-nu";
            rev = "0bb9a602d9bc94b66fab96ce51d46a5a227ab76c";
            hash = "sha256-A5GiOpITOv3H0wytCv6t43buQ8IzxEXrk3gTlOrO0K0=";
          };
          meta.homepage = "https://github.com/nushell/tree-sitter-nu";
        };
        defaultText = "See code";
      };
    };

    lsp = {
      enable = mkEnableOption "Nu LSP support" // {default = config.vim.languages.enableLSP;};
      server = mkOption {
        description = "Nu LSP server to use";
        type = str;
        default = defaultServer;
      };

      package = mkOption {
        description = "Nu LSP server package, or the command to run as a list of strings";
        example = ''[(lib.getExe pkgs.nushell) "--lsp"]'';
        type = either package (listOf str);
        default = servers.${cfg.lsp.server}.package;
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
