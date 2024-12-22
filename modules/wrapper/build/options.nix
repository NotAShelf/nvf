{lib, ...}: let
  inherit (lib.types) package;
  inherit (lib.options) mkOption;
in {
  options.vim.build = {
    finalPackage = mkOption {
      type = package;
      readOnly = true;
      description = "final output package";
    };
  };
}
