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
        '';
      };
    })
    (mkIf cfg.lint_after_save {
      vim = {
        augroups = [{name = "nvf_nvim_lint";}];
        autocmds = [
          {
            event = ["BufWritePost"];
            callback = mkLuaInline ''
              function()
                require("lint").try_lint()
              end
            '';
          }
        ];
      };
    })
  ];
}
