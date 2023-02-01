{
  pkgs,
  config,
  lib,
  ...
}:
with lib; {
  config = {
    vim.git = {
      enable = mkDefault false;
      gitsigns.enable = mkDefault false;
    };
  };
}
