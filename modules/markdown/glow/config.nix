{
  pkgs,
  config,
  lib,
  ...
}:
with lib; {
  config = {
    vim.markdown = {
      enable = mkDefault false;
      glow.enable = mkDefault false;
    };
  };
}
