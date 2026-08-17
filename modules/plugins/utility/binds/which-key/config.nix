{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.binds.whichKey;
  register = mapAttrsToList (n: v: lib.lists.optional (v != null) (mkLuaInline "{ '${n}', desc = '${v}' }")) cfg.register;
in {
  config = mkIf cfg.enable {
    vim.lazy.plugins.which-key-nvim = {
      package = "which-key-nvim";
      setupModule = "which-key";
      inherit (cfg) setupOpts;
      event = ["DeferredUIEnter"];
      cmd = ["WhichKey"];
      after = ''
        require("which-key").add(${toLuaObject register})
      '';
    };
  };
}
