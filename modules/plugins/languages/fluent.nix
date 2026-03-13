{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkIf;

  cfg = config.vim.languages.fluent;
in {
  options.vim.languages.fluent = {
    enable = mkEnableOption "Fluent language support";
  };

  config = mkIf cfg.enable {
    vim = {
      lazy.plugins.fluent-nvim = {
        package = "fluent-nvim";
        ft = ["fluent"];
      };
      autocmds = [
        {
          event = [
            "BufRead"
            "BufNewFile"
          ];
          pattern = ["*.ftl"];
          desc = "Set fluent filetype";
          command = "set filetype=fluent";
        }
      ];
    };
  };
}
