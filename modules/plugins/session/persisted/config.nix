{
  config,
  options,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.binds) mkKeymap;

  cfg = config.vim.session.persisted;
  mappings = options.vim.session.persisted.mappings;
in {
  config = mkIf cfg.enable {
    vim.lazy.plugins.persisted = {
      package = "persisted";
      setupModule = "persisted";
      cmd = ["Persisted"];
      event = ["BufReadPre"];
      inherit (cfg) setupOpts;

      keys = [
        (mkKeymap "n" cfg.mappings.load "function() require('persisted').load() end" {
          desc = mappings.load.description;
          lua = true;
        })

        (mkKeymap "n" cfg.mappings.select "function() require('persisted').select() end" {
          desc = mappings.select.description;
          lua = true;
        })
      ];
    };
  };
}
