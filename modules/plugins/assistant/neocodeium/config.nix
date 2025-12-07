{
  config,
  lib,
  options,
  ...
}: let
  inherit (lib.nvim.binds) mkKeymap;
  cfg = config.vim.assistant.neocodeium;

  inherit (options.vim.assistant.neocodeium) keymaps;
  mkNeoCodeiumKey = act: (mkKeymap "i" cfg.keymaps.${act} "function() require('neocodeium').${act}() end" {
    lua = true;
    desc = keymaps.${act}.description;
  });
in {
  config = lib.mkIf cfg.enable {
    vim = {
      lazy.plugins.neocodeium = {
        package = "neocodeium";
        setupModule = "neocodeium";
        inherit (cfg) setupOpts;
      };
      keymaps = [
        (mkNeoCodeiumKey "accept")
        (mkNeoCodeiumKey "accept_word")
        (mkNeoCodeiumKey "accept_line")
        (mkNeoCodeiumKey "cycle_or_complete")
        (mkNeoCodeiumKey "cycle_or_complete_reverse")
        (mkNeoCodeiumKey "clear")
      ];
    };
  };
}
