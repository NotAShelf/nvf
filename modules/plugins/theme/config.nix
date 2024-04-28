{lib, ...}: let
  inherit (lib.modules) mkDefault;
in {
  config = {
    vim.theme = {
      enable = mkDefault false;
      name = mkDefault "onedark";
      style = mkDefault "darker";
      transparent = mkDefault false;
      extraConfig = mkDefault "";
    };
  };
}
