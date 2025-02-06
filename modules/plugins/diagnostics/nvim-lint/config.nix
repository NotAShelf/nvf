{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.diagnostics.nvim-lint;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["nvim-lint"];
      pluginRC.nvim-lint = let
        mappedLinters =
          lib.concatMapAttrsStringSep "\n" (name: value: ''
            local linter_${name} = lint.linters.${name}
            linter_${name}.args = ${toLuaObject value}
          '')
          cfg.configuredLinters;
      in
        entryAnywhere ''
          local lint = require("lint")
          ${mappedLinters}
          lint.linters_by_ft = ${toLuaObject cfg.setupOpts.linters_by_ft};

          -- TODO: one way of doing this dynamically is to use take required
          -- parameters like fts, commands, arguments and everything expected
          -- by nvim-lint to simply construct multiple autocommands. nvim-lint
          -- doesn't seem to be able to handle that by itself.
          vim.api.nvim_create_autocmd({ "BufWritePost" }, {
            callback = function()
              -- try_lint without arguments runs the linters defined in `linters_by_ft`
              -- for the current filetype
              require("lint").try_lint()
            end,
          })
        '';
    };
  };
}
