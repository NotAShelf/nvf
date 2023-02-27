{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.assistant.tabnine;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = ["tabnine-nvim"];

    vim.luaConfigRC.tabnine-nvim = nvim.dag.entryAnywhere ''
      require('tabnine').setup({
        disable_auto_comment = ${boolToString cfg.disable_auto_comment},
        accept_keymap = ${cfg.accept_keymap},
        dismiss_keymap = ${cfg.dismiss_keymap},
        debounce_ms = ${cfg.debounce_ms},
      execlude_filetypes = ${cfg.execlude_filetypes},
      })
    '';
  };
}
