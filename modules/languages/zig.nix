{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.languages.zig;
in {
  options.vim.languages.zig = {
    enable = mkEnableOption "SQL language support";

    treesitter = {
      enable = mkOption {
        description = "Enable Zig treesitter";
        type = types.bool;
        default = config.vim.languages.enableTreesitter;
      };
      package = nvim.types.mkGrammarOption pkgs "zig";
    };
    lsp = {
      enable = mkOption {
        description = "Zig LSP support (zls)";
        type = types.bool;
        default = config.vim.languages.enableLSP;
      };
      package = mkOption {
        description = "ZLS package";
        type = types.package;
        default = pkgs.nodePackages.pyright;
      };
      zigPackage = mkOption {
        description = "Zig package used by ZLS";
        type = types.package;
        default = pkgs.zig;
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
      vim.lsp.lspconfig.sources.zig-lsp = ''
        lspconfig.zls.setup {
          capabilities = capabilities,
          on_attach=default_on_attach,
          cmd = {"${cfg.lsp.package}/bin/zls"},
          settings = {
            ["zls"] = {
              zig_exe_path = "${cfg.lsp.zigPackage}/bin/zig",
              zig_lib_path = "${cfg.lsp.zigPackage}/lib/zig",
            }
          }
        }
      '';
    })
  ]);
}
