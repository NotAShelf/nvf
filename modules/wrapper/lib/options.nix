{lib, ...}: let
  inherit (lib.options) mkOption;
  inherit (lib.types) attrsOf raw;
in {
  options.vim.lib = mkOption {
    # The second type should be one without merge semantics and which allows function values.
    type = attrsOf raw;
    default = {};
    internal = true;
  };
}
