{lib, ...}: let
  inherit (lib.modules) mkRenamedOptionModule;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.nvim.types) luaInline;
  inherit (lib.nvim.binds) mkMappingOption;
  inherit (lib.generators) mkLuaInline;
in {
  imports = [
    (mkRenamedOptionModule ["vim" "visuals" "cellularAutomaton"] ["vim" "visuals" "cellular-automaton"])
  ];

  options.vim.visuals.cellular-automaton = {
    enable = mkEnableOption "cellular-automaton to help you cope with stubborn code [cellular-automaton]";

    mappings = {
      makeItRain = mkMappingOption config.vim.enableNvfKeymaps "Make it rain [cellular-automaton]" "<leader>fml";
    };

    animation = {
      register = mkEnableOption "registering configured animation(s) automatically" // {default = true;};
      setup = mkOption {
        type = luaInline;
        default = mkLuaInline ''
          local ca_config = {
            fps = 50,
            name = 'slide',
          }

          -- init function is invoked only once at the start
          -- config.init = function (grid)
          --
          -- end

          -- update function
          ca_config.update = function (grid)
          for i = 1, #grid do
            local prev = grid[i][#(grid[i])]
              for j = 1, #(grid[i]) do
                grid[i][j], prev = prev, grid[i][j]
              end
            end
            return true
          end
        '';
        description = ''
          Configuration used to generate an animation to be registered.

          The final value for `ca_config` will be used to register a new
          animation using `require("cellular-automaton").register_animation(ca_config)`

          ::: {.warning}
            `ca_config` **must** eval to a valid Lua table. nvf does not and cannot
            perform any kind of validation on your Lua code, so bogus values will
            result in errors when the animation is registered.
          :::
        '';
      };
    };
  };
}
