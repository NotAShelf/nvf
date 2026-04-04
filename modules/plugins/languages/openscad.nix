{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption literalExpression;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum listOf;
  inherit (lib.meta) getExe;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.openscad;
  /*
  There is no Treesitter module for OpenSCAD yet.
  Luckily vim already ships with a builtin syntax that is used by default.

  The LSP already ships with diagnostics, but there is also an experimental analyzer called sca2d
  <https://search.nixos.org/packages?channel=unstable&query=sca2d>
  But it isn't packaged for nvim-lint and would need extra work.
  */

  defaultServers = ["openscad-lsp"];
  servers = {
    openscad-lsp = {
      enable = true;
      cmd = [(getExe pkgs.openscad-lsp) "--stdio"];
      filetypes = ["openscad"];
    };
  };
in {
  options.vim.languages.openscad = {
    enable = mkEnableOption "OpenSCAD language support";

    lsp = {
      enable =
        mkEnableOption "OpenSCAD LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };

      servers = mkOption {
        type = listOf (enum (attrNames servers));
        default = defaultServers;
        description = "OpenSCAD LSP server to use";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
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
