{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.vim.utility.hop;
in {
  options.vim.utility.hop = {
    enable = mkOption {
      type = types.bool;
      description = "Enable Hop plugin (easy motion)";
    };
  };
}
