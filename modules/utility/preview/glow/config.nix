{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.binds) mkBinding;
  inherit (lib.nvim.dag) entryAnywhere;
  # TODO: move this to its own module
  inherit (lib) pushDownDefault;

  cfg = config.vim.utility.preview.glow;
  self = import ./glow.nix {
    inherit lib config pkgs;
  };
  mappings = self.options.vim.utility.preview.glow.mappings;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = ["glow-nvim"];

    vim.maps.normal = mkMerge [
      (mkBinding cfg.mappings.openPreview ":Glow<CR>" mappings.openPreview.description)
    ];

    vim.binds.whichKey.register = pushDownDefault {
      "<leader>pm" = "+Preview Markdown";
    };

    vim.luaConfigRC.glow = entryAnywhere ''
      require('glow').setup({
        glow_path = "${pkgs.glow}/bin/glow"
      });
    '';
  };
}
