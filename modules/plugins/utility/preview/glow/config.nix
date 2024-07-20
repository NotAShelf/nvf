{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.binds) mkBinding pushDownDefault;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.utility.preview.glow;
  self = import ./glow.nix {
    inherit lib config pkgs;
  };
  inherit (self.options.vim.utility.preview.glow) mappings;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = ["glow-nvim"];

    vim.maps.normal = mkMerge [
      (mkBinding cfg.mappings.openPreview ":Glow<CR>" mappings.openPreview.description)
    ];

    vim.binds.whichKey.register = pushDownDefault {
      "<leader>pm" = "+Preview Markdown";
    };

    vim.pluginRC.glow = entryAnywhere ''
      require('glow').setup({
        glow_path = "${pkgs.glow}/bin/glow"
      });
    '';
  };
}
