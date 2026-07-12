{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum listOf;
  inherit (lib) genAttrs;
  inherit (config.vim.lib) mkLanguageLspEnableOption;

  cfg = config.vim.languages.openscad;
  /*
  There is no Treesitter module for OpenSCAD yet.
  Luckily vim already ships with a builtin syntax that is used by default.

  The LSP already ships with diagnostics, but there is also an experimental analyzer called sca2d
  <https://search.nixos.org/packages?channel=unstable&query=sca2d>
  But it isn't packaged for nvim-lint and would need extra work.
  */

  defaultServers = ["openscad-lsp"];
  servers = ["openscad-lsp"];
in {
  options.vim.languages.openscad = {
    enable = mkEnableOption "OpenSCAD language support";

    lsp = {
      enable = mkLanguageLspEnableOption {
        option = "openscad";
        display = "OpenSCAD";
      };

      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "OpenSCAD LSP server to use";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = ["openscad"];
        });
      };
    })
  ]);
}
