{
  config,
  lib,
  ...
}: let
  inherit (builtins) toJSON;
  inherit (lib) mkIf mkMerge mkExprBinding boolToString nvim;

  cfg = config.vim.assistant.tabnine;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = ["tabnine-nvim"];

    vim.maps.insert = mkMerge [
      (mkExprBinding cfg.mappings.accept ''
        function()
          local state = require("tabnine.state")
          local completion = require("tabnine.completion")

        	if not state.completions_cache then
          	return "${toJSON cfg.mappings.accept}"
          end

          vim.schedule(completion.accept)
        end
      '' "orzel")
      (mkExprBinding cfg.mappings.dismiss ''
        function()
          local state = require("tabnine.state")
          local completion = require("tabnine.completion")

        	if not state.completions_cache then
          	return "${toJSON cfg.mappings.dismiss}"
          end

          vim.schedule(function()
            completion.clear()
            state.completions_cache = nil
          end)
        end
      '' "orzel")
    ];

    vim.luaConfigRC.tabnine-nvim = nvim.dag.entryAnywhere ''
      require('tabnine').setup({
        disable_auto_comment = ${boolToString cfg.disable_auto_comment},
        accept_keymap = null,
        dismiss_keymap = null,
        debounce_ms = ${cfg.debounce_ms},
        exclude_filetypes = ${cfg.exclude_filetypes},
      })
    '';
  };
}
