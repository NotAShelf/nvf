{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.attrsets) optionalAttrs;
  cfg = config.vim.utility.ccc;
in {
  config = mkIf cfg.enable {
    vim.lazy.plugins."ccc-nvim" =
      {
        package = "ccc-nvim";
        setupModule = "ccc";
        beforeSetup = ''local ccc = require("ccc")'';
        # Omitted CccHighliterDisable since it would only ever be called as the first command
        # if auto_enable was enabled, which would make the cmd option useless anyways
        cmd = ["CccPick" "CccConvert" "CccHighlighterEnable" "CccHighlighterToggle"];
        inherit (cfg) setupOpts;
      }
      // optionalAttrs (cfg.setupOpts.highlighter.auto_enable or false) {
        event = [
          {
            event = "User";
            pattern = "LazyFile";
          }
        ];
      };
  };
}
