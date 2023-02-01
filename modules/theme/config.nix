{ pkgs, config, lib, ... }:
with lib; {
  config = {
    vim.theme = {
      enable = mkDefault false;
      name = mkDefault "onedark";
      style = mkDefault "darker";
      extraConfig = mkDefault "";
    };
  };
}
