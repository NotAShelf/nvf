{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;

  cfg = config.vim.formatter.conform-nvim.presets.php-cs-fixer;
in {
  options.vim.formatter.conform-nvim.presets.php-cs-fixer = {
    enable = mkFormatterPresetEnableOption {
      option = "php-cs-fixer";
      display = "PHP Coding Standards Fixer";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.php-cs-fixer = {
      command = "${pkgs.php85Packages.php-cs-fixer}/bin/php-cs-fixer";
      stdin = false;
      args = ["fix" "$FILENAME"];
    };
  };
}
