{
  config,
  lib,
  ...
}: let
  inherit (lib.strings) concatStringsSep;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.utility.ccc;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = ["ccc-nvim"];

    vim.pluginRC.ccc = entryAnywhere ''
      local ccc = require("ccc")
      ccc.setup {
      	highlighter = {
      		auto_enable = true,
      		max_byte = 2 * 1024 * 1024, -- 2mb
      		lsp = true,
      		filetypes = colorPickerFts,
      	},
      	pickers = {
      		ccc.picker.hex,
      		ccc.picker.css_rgb,
      		ccc.picker.css_hsl,
      		ccc.picker.ansi_escape {
      			meaning1 = "bright", -- whether the 1 means bright or yellow
      		},
      	},
      	alpha_show = "hide", -- needed when highlighter.lsp is set to true
      	recognize = { output = true }, -- automatically recognize color format under cursor
      	inputs = {${concatStringsSep "," (map (input: "ccc.input.${input}") cfg.inputs)}},
      	outputs = {${concatStringsSep "," (map (output: "ccc.output.${output}") cfg.outputs)}},
      	convert = {
      		{ ccc.picker.hex, ccc.output.css_hsl },
      		{ ccc.picker.css_rgb, ccc.output.css_hsl },
      		{ ccc.picker.css_hsl, ccc.output.hex },
      	},
      	mappings = {
      		["q"] = ccc.mapping.quit,
      		["L"] = ccc.mapping.increase10,
      		["H"] = ccc.mapping.decrease10,
      	},
      }
    '';
  };
}
