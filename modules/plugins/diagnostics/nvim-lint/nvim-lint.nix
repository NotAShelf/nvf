{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) attrsOf listOf str;
in {
  options.vim.diagnostics.nvim-lint = {
    enable = mkEnableOption "asynchronous linter plugin for Neovim [nvim-lint]";

    # nvim-lint does not have a setup table.
    linters_by_ft = mkOption {
      type = attrsOf (listOf str);
      default = {};
      example = {
        text = ["vale"];
        markdown = ["vale"];
      };
      description = ''
        Map of filetype to formatters. This option takes a set of `key = value`
        format where the `value` will be converted to its Lua equivalent
        through `toLuaObject. You are responsible for passing the correct Nix
        data types to generate a correct Lua value that conform is able to
        accept.
      '';
    };
  };
}
