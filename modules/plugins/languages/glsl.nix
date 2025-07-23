{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) enum listOf;
  inherit (lib.meta) getExe;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.glsl;

  defaultServers = ["glsl_analyzer"];
  servers = {
    glsl_analyzer = {
      enable = true;
      cmd = [(getExe pkgs.glsl_analyzer)];
      filetypes = ["glsl" "vert" "tesc" "tese" "frag" "geom" "comp"];
      root_markers = [".git"];
    };
  };
in {
  options.vim.languages.glsl = {
    enable = mkEnableOption "GLSL language support";

    treesitter = {
      enable = mkEnableOption "GLSL treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "glsl";
    };

    lsp = {
      enable = mkEnableOption "GLSL LSP support" // {default = config.vim.lsp.enable;};

      servers = mkOption {
        type = listOf (enum (attrNames servers));
        default = defaultServers;
        description = "GLSL LSP server to use";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter = {
        enable = true;
        grammars = [cfg.treesitter.package];
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
