{
  config,
  lib,
  ...
}: let
  inherit (lib) addDescriptionsToMappings mkIf nvim;

  cfg = config.vim.utility.ccc;
  self = import ./ccc.nix {inherit lib;};

  mappingDefinitions = self.options.vim.utility.ccc.mappings;
  mappings = addDescriptionsToMappings cfg.mappings mappingDefinitions;
in {
  config = mkIf (cfg.enable) {
    vim.startPlugins = [
      "ccc"
    ];

    vim.luaConfigRC.ccc = nvim.dag.entryAnywhere ''
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
      	inputs = { ccc.input.hsl },
      	outputs = {
      		ccc.output.css_hsl,
      		ccc.output.css_rgb,
      		ccc.output.hex,
      	},
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
