{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.diagnostics.nvim-lint;
in {
  config = mkMerge [
    (mkIf cfg.enable {
      vim = {
        startPlugins = ["nvim-lint"];
        pluginRC.nvim-lint = entryAnywhere ''
          require("lint").linters_by_ft = ${toLuaObject cfg.linters_by_ft}

          local linters = require("lint").linters
          local nvf_linters = ${toLuaObject cfg.linters}
          for linter, config in pairs(nvf_linters) do
            if linters[linter] == nil then
              linters[linter] = config
            else
              for key, val in pairs(config) do
                linters[linter][key] = val
              end
            end
          end

          nvf_lint = ${toLuaObject cfg.lint_function}
        '';
      };
    })
    (mkIf (cfg.enable && cfg.lint_after_save) {
      vim = {
        augroups = [{name = "nvf_nvim_lint";}];
        autocmds = [
          {
            event = ["BufWritePost"];
            callback = mkLuaInline ''
              function(args)
                nvf_lint(args.buf)
              end
            '';
          }
        ];
      };
    })
  ];
}
