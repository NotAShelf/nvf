{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.types) str;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.utility.vim-wakatime = {
    enable = mkEnableOption ''
      automatic time tracking and metrics generated from your programming activity [vim-wakatime]
    '';

    setupOpts = mkPluginSetupOption "vim-wakatime" {
      cli_path = mkOption {
        type = str;
        default = lib.getExe' pkgs.wakatime-cli "wakatime-cli";
        defaultText = literalExpression "lib.getExe' pkgs.wakatime-cli \"wakatime-cli\"";
        example = literalExpression "wakatime-cli";
        description = ''
          Path to wakatime-cli executable. Set to `"wakatime-cli"` to get `wakatime-cli` from {env}`PATH`.
        '';
      };
    };
  };
}
