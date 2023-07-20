{
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  options.vim.ui.breadcrumbs = {
    enable = lib.mkEnableOption "breadcrumbs";

    navbuddy = {
      enable = mkEnableOption "navbuddy LSP UI";
      useDefaultMappings = mkEnableOption "default Navbuddy keybindings (disables user keybinds)";

      window = {
        # size = {}
        # position = {}

        border = mkOption {
          # TODO: let this type accept a custom string
          type = types.enum ["single" "rounded" "double" "solid" "none"];
          default = "single";
          description = "border style to use";
        };

        scrolloff = mkOption {
          type = with types; nullOr int;
          default = null;
          description = "Scrolloff value within navbuddy window";
        };

        sections = {
          # left section
          left = {
            #size = {}
            border = mkOption {
              # TODO: let this type accept a custom string
              type = with types; nullOr (enum ["single" "rounded" "double" "solid" "none"]);
              default = null;
              description = "border style to use for the left section of Navbuddy UI";
            };
          };

          # middle section
          mid = {
            #size = {}
            border = mkOption {
              # TODO: let this type accept a custom string
              type = with types; nullOr (enum ["single" "rounded" "double" "solid" "none"]);
              default = null;
              description = "border style to use for the middle section of Navbuddy UI";
            };
          };

          # right section
          # there is no size option for the right section, it fills the remaining space
          right = {
            border = mkOption {
              # TODO: let this type accept a custom string
              type = with types; nullOr (enum ["single" "rounded" "double" "solid" "none"]);
              default = null;
              description = "border style to use for the right section of Navbuddy UI";
            };

            preview = mkOption {
              type = types.enum ["leaf" "always" "never"];
              default = "leaf";
              description = "display mode of the preview on the right section";
            };
          };
        };
      };

      nodeMarkers = {
        enable = mkEnableOption "node markers";
        icons = {
          leaf = mkOption {
            type = types.str;
            default = "  ";
            description = "";
          };

          leafSelected = mkOption {
            type = types.str;
            default = " → ";
            description = "";
          };

          branch = mkOption {
            type = types.str;
            default = " ";
            description = "";
          };
        };
      };

      lsp = {
        autoAttach = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to attach to LSP server manually";
        };

        preference = mkOption {
          type = with types; nullOr (listOf str);
          default = null;
          description = "list of lsp server names in order of preference";
        };
      };

      sourceBuffer = {
        followNode = mkOption {
          type = types.bool;
          default = true;
          description = "keep the current node in focus on the source buffer";
        };

        highlight = mkOption {
          type = types.bool;
          default = true;
          description = "highlight the currently focused node";
        };

        reorient = mkOption {
          type = types.enum ["smart" "top" "mid" "none"];
          default = "smart";
        };

        scrolloff = mkOption {
          type = with types; nullOr int;
          default = null;
          description = "scrolloff value when navbuddy is open";
        };
      };

      icons = {};
    };
  };
}
