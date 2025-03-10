{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) attrsOf listOf str;
in {
  options.vim.diagnostics.nvim-lint = {
    # TODO:remove internal
    enable = mkEnableOption "asynchronous linter plugin for Neovim " // {internal = true;};
    linters_by_ft = mkOption {
      internal = true; # TODO: remove
      type = attrsOf (listOf str);
      default = {};
      example = {
        text = ["vale"];
        markdown = ["vale"];
      };

      description = ''
        Map of filetype to formatters. This option takes a set of
        `key = value` format where the `value` will be converted
        to its Lua equivalent. You are responsible for passing the
        correct Nix data types to generate a correct Lua value that
        conform is able to accept.
      '';
    };
  };
}
