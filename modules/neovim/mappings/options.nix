{lib, ...}: let
  inherit (lib.options) mkOption;
  inherit (lib.types) either str listOf attrsOf nullOr submodule bool;
  inherit (lib.nvim.config) mkBool;

  mapConfigOptions = {
    desc = mkOption {
      type = nullOr str;
      default = null;
      description = "A description of this keybind, to be shown in which-key, if you have it enabled.";
    };

    action = mkOption {
      type = str;
      description = "The command to execute.";
    };
    lua = mkBool false ''
      If true, `action` is considered to be lua code.
      Thus, it will not be wrapped in `""`.
    '';

    silent = mkBool true "Whether this mapping should be silent. Equivalent to adding <silent> to a map.";
    nowait = mkBool false "Whether to wait for extra input on ambiguous mappings. Equivalent to adding <nowait> to a map.";
    script = mkBool false "Equivalent to adding <script> to a map.";
    expr = mkBool false "Means that the action is actually an expression. Equivalent to adding <expr> to a map.";
    unique = mkBool false "Whether to fail if the map is already defined. Equivalent to adding <unique> to a map.";
    noremap = mkBool true "Whether to use the 'noremap' variant of the command, ignoring any custom mappings on the defined action. It is highly advised to keep this on, which is the default.";
  };

  mapType = submodule {
    options =
      mapConfigOptions
      // {
        key = mkOption {
          type = str;
          description = ''
            Key that triggers this keybind.
          '';
        };
        mode = mkOption {
          type = either str (listOf str);
          description = ''
            The short-name of the mode to set the keymapping for. Passing an empty string is the equivalent of `:map`.

            See `:help map-modes` for a list of modes.
          '';
          example = ''`["n" "v" "c"]` for normal, visual and command mode'';
        };
      };
  };

  # legacy stuff
  legacyMapOption = submodule {
    options = mapConfigOptions;
  };

  mapOptions = mode:
    mkOption {
      description = "Mappings for ${mode} mode";
      type = attrsOf legacyMapOption;
      default = {};
    };
in {
  options.vim = {
    keymaps = mkOption {
      type = listOf mapType;
      description = "Custom keybindings.";
      example = ''
        vim.keymaps = [
          {
            key = "<leader>m";
            mode = "n";
            silent = true;
            action = ":make<CR>";
          }
          {
            key = "<leader>l";
            mode = ["n" "x"];
            silent = true;
            action = "<cmd>cnext<CR>";
          }
        ];
      '';
      default = {};
    };

    maps = {
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
}
