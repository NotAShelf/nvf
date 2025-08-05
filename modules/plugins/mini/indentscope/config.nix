{
  config,
  lib,
  ...
}: let
  inherit (lib.generators) mkLuaInline;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.mini.indentscope;
in {
  vim = mkIf cfg.enable {
    autocmds = [
      {
        callback = mkLuaInline ''
          function()
            local ignore_filetypes = ${toLuaObject cfg.setupOpts.ignore_filetypes}
            if vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
              vim.b.miniindentscope_disable = true
            end
          end
        '';
        desc = "Disable indentscope for certain filetypes";
        event = ["FileType"];
      }
    ];

    startPlugins = ["mini-indentscope"];

    pluginRC.mini-indentscope = entryAnywhere ''
      require("mini.indentscope").setup(${toLuaObject cfg.setupOpts})
    '';
  };
}
