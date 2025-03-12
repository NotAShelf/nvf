{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.strings) fileContents;
in {
  options.vim.healthcheck = {
    enable = mkEnableOption "nvf healthchecks";
  };

  config = {
    vim.additionalRuntimePaths = [
      (pkgs.writeTextDir "autoload/health/nvf.lua" (fileContents ./autoload.lua)).outPath
    ];
  };
}
