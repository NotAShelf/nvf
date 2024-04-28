{lib, ...}: let
  inherit (lib.options) mkOption;
  inherit (lib.types) bool str attrsOf nullOr submodule;
  inherit (lib.nvim.config) mkBool;
  # Most of the keybindings code is highly inspired by pta2002/nixvim.
  # Thank you!
  mapConfigOptions = {
    silent =
      mkBool false
      "Whether this mapping should be silent. Equivalent to adding <silent> to a map.";

    nowait =
      mkBool false
      "Whether to wait for extra input on ambiguous mappings. Equivalent to adding <nowait> to a map.";

    script =
      mkBool false
      "Equivalent to adding <script> to a map.";

    expr =
      mkBool false
      "Means that the action is actually an expression. Equivalent to adding <expr> to a map.";

    unique =
      mkBool false
      "Whether to fail if the map is already defined. Equivalent to adding <unique> to a map.";

    noremap =
      mkBool true
      "Whether to use the 'noremap' variant of the command, ignoring any custom mappings on the defined action. It is highly advised to keep this on, which is the default.";

    desc = mkOption {
      type = nullOr str;
      default = null;
      description = "A description of this keybind, to be shown in which-key, if you have it enabled.";
    };
  };

  mapOption = submodule {
    options =
      mapConfigOptions
      // {
        action = mkOption {
          type = str;
          description = "The action to execute.";
        };

        lua = mkOption {
          type = bool;
          description = ''
            If true, `action` is considered to be lua code.
            Thus, it will not be wrapped in `""`.
          '';
          default = false;
        };
      };
  };

  mapOptions = mode:
    mkOption {
      description = "Mappings for ${mode} mode";
      type = attrsOf mapOption;
      default = {};
    };
in {
  options.vim = {
    maps = mkOption {
      type = submodule {
        options = {
          normal = mapOptions "normal";
          insert = mapOptions "insert";
          select = mapOptions "select";
          visual = mapOptions "visual and select";
          terminal = mapOptions "terminal";
          normalVisualOp = mapOptions "normal, visual, select and operator-pending (same as plain 'map')";

          visualOnly = mapOptions "visual only";
          operator = mapOptions "operator-pending";
          insertCommand = mapOptions "insert and command-line";
          lang = mapOptions "insert, command-line and lang-arg";
          command = mapOptions "command-line";
        };
      };
      default = {};
      description = ''
        Custom keybindings for any mode.

        For plain maps (e.g. just 'map' or 'remap') use `maps.normalVisualOp`.
      '';

      example = ''
        maps = {
          normal."<leader>m" = {
            silent = true;
            action = "<cmd>make<CR>";
          }; # Same as nnoremap <leader>m <silent> <cmd>make<CR>
        };
      '';
    };
  };
}
