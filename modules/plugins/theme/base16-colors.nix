{lib}: let
  inherit (lib.options) mkOption;
  inherit (lib.nvim.types) hexColorType;
in {
  base00 = mkOption {
    type = hexColorType;
    default = "#1e1e2e";
  };
  base01 = mkOption {
    type = hexColorType;
    default = "#181825";
  };
  base02 = mkOption {
    type = hexColorType;
    default = "#313244";
  };
  base03 = mkOption {
    type = hexColorType;
    default = "#45475a";
  };
  base04 = mkOption {
    type = hexColorType;
    default = "#585b70";
  };
  base05 = mkOption {
    type = hexColorType;
    default = "#cdd6f4";
  };
  base06 = mkOption {
    type = hexColorType;
    default = "#f5e0dc";
  };
  base07 = mkOption {
    type = hexColorType;
    default = "#b4befe";
  };
  base08 = mkOption {
    type = hexColorType;
    default = "#f38ba8";
  };
  base09 = mkOption {
    type = hexColorType;
    default = "#fab387";
  };
  base0A = mkOption {
    type = hexColorType;
    default = "#a6e3a1";
  };
  base0B = mkOption {
    type = hexColorType;
    default = "#94e2d5";
  };
  base0C = mkOption {
    type = hexColorType;
    default = "#a6e3a1";
  };
  base0D = mkOption {
    type = hexColorType;
    default = "#89b4fa";
  };
  base0E = mkOption {
    type = hexColorType;
    default = "#cba6f4";
  };
  base0F = mkOption {
    type = hexColorType;
    default = "#f2cdcd";
  };
}
