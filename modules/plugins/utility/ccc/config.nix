{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.generators) mkLuaInline;
  cfg = config.vim.utility.ccc;
  mkLuaIdentifier = prefix: identifier: mkLuaInline "${prefix}${identifier}";
  mapSetupOptions = setupOpts:
    setupOpts
    // {
      inputs = map (mkLuaIdentifier "ccc.input.") setupOpts.inputs;
      outputs = map (mkLuaIdentifier "ccc.output.") setupOpts.outputs;
    };
in {
  config = mkIf cfg.enable {
    vim.startPlugins = ["ccc-nvim"];

    vim.pluginRC.ccc = entryAnywhere ''
      local ccc = require("ccc")
      ccc.setup(${toLuaObject (mapSetupOptions cfg.setupOpts)})
    '';
  };
}
