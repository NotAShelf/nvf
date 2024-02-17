{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) isList nvim mkEnableOption mkOption types mkIf mkMerge;

  cfg = config.vim.languages.zig;
in {
  options.vim.languages.zig = {
    enable = mkEnableOption "Zig language support";

    treesitter = {
      enable = mkEnableOption "Zig treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = nvim.types.mkGrammarOption pkgs "zig";
    };

    lsp = {
      enable = mkEnableOption "Zig LSP support (zls)" // {default = config.vim.languages.enableLSP;};

      package = mkOption {
        description = "ZLS package, or the command to run as a list of strings";
        example = ''[lib.getExe pkgs.jdt-language-server "-data" "~/.cache/jdtls/workspace"]'';
        type = with types; either package (listOf str);
        default = pkgs.zls;
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
          cmd = ${
          if isList cfg.lsp.package
          then nvim.lua.expToLua cfg.lsp.package
          else ''{"${cfg.lsp.package}/bin/zls"}''
        },
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
