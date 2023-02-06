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
  options.vim.assistant.tabnine = {
    enable = mkEnableOption "Enable TabNine assistant";
  };

  config = mkIf cfg.enable {
    vim.startPlugins = ["tabnine-nvim"];

    vim.luaConfigRC.tabnine-nvim = nvim.dag.entryAnywhere ''
      require('tabnine').setup({
        disable_auto_comment=true,
        accept_keymap="<Tab>",
        dismiss_keymap = "<C-]>",
        debounce_ms = 800,
      execlude_filetypes = {"TelescopePrompt", "NvimTree", "alpha"}
      })
    '';
  };
}
