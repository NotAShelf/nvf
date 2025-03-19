{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.strings) optionalString;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAnywhere entryAfter;
  inherit (lib.nvim.binds) mkBinding;

  cfg = config.vim.visuals.cellular-automaton;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["cellular-automaton-nvim"];

      maps.normal = mkBinding cfg.mappings.makeItRain "<cmd>CellularAutomaton make_it_rain<CR>" "Make it rain";

      pluginRC = {
        # XXX: This has no error handling. User can set
        # `animation.setup` to a bogus value, and we would
        # have an error in our hands. I don't think there
        # is a good way to check for errors, so I'm leaving
        # it like this under the assumption that the user
        # will not mess it up for no reason.
        cellular-automaton-anim = entryAnywhere (optionalString cfg.animation.register ''
          -- Coerce user animation config into pluginRC
          ${toLuaObject cfg.animation.setup}
        '');

        cellular-automaton = entryAfter ["cellular-automaton-anim"] ''
          -- Register the animation
          require("cellular-automaton").register_animation(ca_config)
        '';
      };
    };
  };
}
