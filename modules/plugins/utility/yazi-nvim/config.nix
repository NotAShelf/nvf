{
  options,
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.binds) mkKeymap;

  cfg = config.vim.utility.yazi-nvim;
  keys = cfg.mappings;

  inherit (options.vim.utility.yazi-nvim) mappings;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["snacks-nvim"];
      lazy.plugins."yazi.nvim" = {
        package = pkgs.vimPlugins.yazi-nvim;
        setupModule = "yazi";
        inherit (cfg) setupOpts;
        event = ["BufAdd" "VimEnter"];

        keys = [
          (mkKeymap "n" keys.openYazi "<cmd>Yazi<CR>" {desc = mappings.openYazi.description;})
          (mkKeymap "n" keys.openYaziDir "<cmd>Yazi cwd<CR>" {desc = mappings.openYaziDir.description;})
          (mkKeymap "n" keys.yaziToggle "<cmd>Yazi toggle<CR>" {desc = mappings.yaziToggle.description;})
        ];
      };
    };
  };
}
