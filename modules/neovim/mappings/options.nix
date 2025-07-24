{lib, ...}: let
  inherit (lib.options) mkOption literalMD mkEnableOption;
  inherit (lib.types) either str listOf attrsOf nullOr submodule;
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
          type = nullOr str;
          description = "The key that triggers this keybind.";
        };
        mode = mkOption {
          type = either str (listOf str);
          description = ''
            The short-name of the mode to set the keymapping for. Passing an empty string is the equivalent of `:map`.

            See `:help map-modes` for a list of modes.
          '';
          example = literalMD ''`["n" "v" "c"]` for normal, visual and command mode'';
        };
      };
  };

  legacyMapOption = mode:
    mkOption {
      description = "Mappings for ${mode} mode";
      type = attrsOf (submodule {
        options = mapConfigOptions;
      });
      default = {};
    };
in {
  options.vim = {
    enableNvfKeymaps = mkEnableOption "default NVF keymaps for plugins" // {default = true;};
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
      normal = legacyMapOption "normal";
      insert = legacyMapOption "insert";
      select = legacyMapOption "select";
      visual = legacyMapOption "visual and select";
      terminal = legacyMapOption "terminal";
      normalVisualOp = legacyMapOption "normal, visual, select and operator-pending (same as plain 'map')";

      visualOnly = legacyMapOption "visual only";
      operator = legacyMapOption "operator-pending";
      insertCommand = legacyMapOption "insert and command-line";
      lang = legacyMapOption "insert, command-line and lang-arg";
      command = legacyMapOption "command-line";
    };
  };
}
