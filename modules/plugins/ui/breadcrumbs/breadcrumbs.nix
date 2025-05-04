{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) nullOr listOf enum bool str int;
  inherit (lib.modules) mkRenamedOptionModule;
  inherit (lib.nvim.types) mkPluginSetupOption borderType;
  mkSimpleIconOption = default:
    mkOption {
      inherit default;
      type = str;
      description = "";
    };
in {
  imports = let
    renameSetupOpt = oldPath: newPath:
      mkRenamedOptionModule
      (["vim" "ui" "breadcrumbs" "navbuddy"] ++ oldPath)
      (["vim" "ui" "breadcrumbs" "navbuddy" "setupOpts"] ++ newPath);
  in [
    (renameSetupOpt ["useDefaultMappings"] ["use_default_mappings"])
    (renameSetupOpt ["window"] ["window"])
    (renameSetupOpt ["nodeMarkers"] ["node_markers"])
    (renameSetupOpt ["lsp" "autoAttach"] ["lsp" "auto_attach"])
    (renameSetupOpt ["lsp" "preference"] ["lsp" "preference"])
    (renameSetupOpt ["sourceBuffer" "followNode"] ["source_buffer" "follow_node"])
    (renameSetupOpt ["sourceBuffer" "highlight"] ["source_buffer" "highlight"])
    (renameSetupOpt ["sourceBuffer" "reorient"] ["source_buffer" "reorient"])
    (renameSetupOpt ["sourceBuffer" "scrolloff"] ["source_buffer" "scrolloff"])
    # TODO: every option under icon is renamed to first letter capitalized
    (renameSetupOpt ["icon"] ["icon"])

    (mkRenamedOptionModule ["vim" "ui" "breadcrumbs" "alwaysRender"] ["vim" "ui" "breadcrumbs" "lualine" "winbar" "alwaysRender"])
  ];

  options.vim.ui.breadcrumbs = {
    enable = mkEnableOption "breadcrumbs";
    source = mkOption {
      type = nullOr (enum ["nvim-navic"]); # TODO: lspsaga and dropbar
      default = "nvim-navic";
      description = ''
        The source to be used for breadcrumbs component. Null means no breadcrumbs.
      '';
    };

    # Options for configuring Lualine integration of nvim-navic
    lualine.winbar = {
      enable = mkOption {
        type = bool;
        default = true; # for retaining previous behaviour
        example = false;
        description = ''
          Whether to automatically configure a winbar component for
          Lualine on the Winbar section.

          ::: {.note}
          This is **set to `true` by default**, which means nvim-navic
          will occupy `winbar.lualine_c` for the breadcrumbs feature
          unless this option is set to `false`.
          :::
        '';
      };

      alwaysRender = mkOption {
        type = bool;
        default = true;
        example = false;
        description = ''
          Whether to always display the breadcrumbs component
          on winbar.

          ::: {.note}
          This will pass `draw_empty` to the `nvim_navic` winbar
          component, which causes the component to be drawn even
          if it's empty.
          :::
        '';
      };
    };

    navbuddy = {
      enable = mkEnableOption "navbuddy LSP helper UI. Enabling this option automatically loads and enables nvim-navic";
      mappings = {
        close = mkOption {
          type = str;
          default = "<esc>";
          description = "Close and return the cursor to its original location.";
        };

        nextSibling = mkOption {
          type = str;
          default = "j";
          description = "Navigate to the next sibling node.";
        };

        previousSibling = mkOption {
          type = str;
          default = "k";
          description = "Navigate to the previous sibling node.";
        };

        parent = mkOption {
          type = str;
          default = "h";
          description = "Navigate to the parent node.";
        };

        children = mkOption {
          type = str;
          default = "l";
          description = "Navigate to the child node.";
        };

        root = mkOption {
          type = str;
          default = "0";
          description = "Navigate to the root node.";
        };

        visualName = mkOption {
          type = str;
          default = "v";
          description = "Select the name visually.";
        };

        visualScope = mkOption {
          type = str;
          default = "V";
          description = "Select the scope visually.";
        };

        yankName = mkOption {
          type = str;
          default = "y";
          description = "Yank the name to system clipboard.";
        };

        yankScope = mkOption {
          type = str;
          default = "Y";
          description = "Yank the scope to system clipboard.";
        };

        insertName = mkOption {
          type = str;
          default = "i";
          description = "Insert at the start of name.";
        };

        insertScope = mkOption {
          type = str;
          default = "I";
          description = "Insert at the start of scope.";
        };

        appendName = mkOption {
          type = str;
          default = "a";
          description = "Insert at the end of name.";
        };

        appendScope = mkOption {
          type = str;
          default = "A";
          description = "Insert at the end of scope.";
        };

        rename = mkOption {
          type = str;
          default = "r";
          description = "Rename the node.";
        };

        delete = mkOption {
          type = str;
          default = "d";
          description = "Delete the node.";
        };

        foldCreate = mkOption {
          type = str;
          default = "f";
          description = "Create a new fold of the node.";
        };

        foldDelete = mkOption {
          type = str;
          default = "F";
          description = "Delete the current fold of the node.";
        };

        comment = mkOption {
          type = str;
          default = "c";
          description = "Comment the node.";
        };

        select = mkOption {
          type = str;
          default = "<enter>";
          description = "Goto the node.";
        };

        moveDown = mkOption {
          type = str;
          default = "J";
          description = "Move the node down.";
        };

        moveUp = mkOption {
          type = str;
          default = "K";
          description = "Move the node up.";
        };

        togglePreview = mkOption {
          type = str;
          default = "s";
          description = "Toggle the preview.";
        };

        vsplit = mkOption {
          type = str;
          default = "<C-v>";
          description = "Open the node in a vertical split.";
        };

        hsplit = mkOption {
          type = str;
          default = "<C-s>";
          description = "Open the node in a horizontal split.";
        };

        telescope = mkOption {
          type = str;
          default = "t";
          description = "Start fuzzy finder at the current level.";
        };

        help = mkOption {
          type = str;
          default = "g?";
          description = "Open the mappings help window.";
        };
      };

      setupOpts = mkPluginSetupOption "navbuddy" {
        useDefaultMappings = mkOption {
          type = bool;
          default = true;
          description = "Add the default Navbuddy keybindings in addition to the keybinding added by this module.";
        };

        window = {
          # size = {}
          # position = {}

          border = mkOption {
            type = borderType;
            default = config.vim.ui.borders.globalStyle;
            description = "The border style to use.";
          };

          scrolloff = mkOption {
            type = nullOr int;
            default = null;
            description = "The scrolloff value within a navbuddy window.";
          };

          sections = {
            # left section
            left = {
              /*
              size = mkOption {
                type = nullOr (intBetween 0 100);
                default = null;
                description = "size of the left section of Navbuddy UI in percentage (0-100)";
              };
              */

              border = mkOption {
                type = borderType;
                default = config.vim.ui.borders.globalStyle;
                description = "The border style to use for the left section of the Navbuddy UI.";
              };
            };

            # middle section
            mid = {
              /*
              size = {
                type = nullOr (intBetween 0 100);
                default = null;
                description = "size of the left section of Navbuddy UI in percentage (0-100)";
              };
              */

              border = mkOption {
                type = borderType;
                default = config.vim.ui.borders.globalStyle;
                description = "The border style to use for the middle section of the Navbuddy UI.";
              };
            };

            # right section
            # there is no size option for the right section, it fills the remaining space
            right = {
              border = mkOption {
                type = borderType;
                default = config.vim.ui.borders.globalStyle;
                description = "The border style to use for the right section of the Navbuddy UI.";
              };

              preview = mkOption {
                type = enum ["leaf" "always" "never"];
                default = "leaf";
                description = "The display mode of the preview on the right section.";
              };
            };
          };
        };

        node_markers = {
          enable = mkEnableOption "node markers";
          icons = {
            leaf = mkSimpleIconOption "  ";
            leaf_selected = mkSimpleIconOption " → ";
            branch = mkSimpleIconOption " ";
          };
        };

        lsp = {
          auto_attach = mkOption {
            type = bool;
            default = true;
            description = "Whether to attach to LSP server manually.";
          };

          preference = mkOption {
            type = nullOr (listOf str);
            default = null;
            description = "The preference list ranking LSP servers.";
          };
        };

        source_buffer = {
          followNode = mkOption {
            type = bool;
            default = true;
            description = "Whether to keep the current node in focus in the source buffer.";
          };

          highlight = mkOption {
            type = bool;
            default = true;
            description = "Whether to highlight the currently focused node in the source buffer.";
          };

          reorient = mkOption {
            type = enum ["smart" "top" "mid" "none"];
            default = "smart";
            description = "The mode for reorienting the source buffer after moving nodes.";
          };

          scrolloff = mkOption {
            type = nullOr int;
            default = null;
            description = "The scrolloff value in the source buffer when Navbuddy is open.";
          };
        };

        icons = {
          File = mkSimpleIconOption "󰈙 ";
          Module = mkSimpleIconOption " ";
          Namespace = mkSimpleIconOption "󰌗 ";
          Package = mkSimpleIconOption " ";
          Class = mkSimpleIconOption "󰌗 ";
          Property = mkSimpleIconOption " ";
          Field = mkSimpleIconOption " ";
          Constructor = mkSimpleIconOption " ";
          Enum = mkSimpleIconOption "󰕘";
          Interface = mkSimpleIconOption "󰕘";
          Function = mkSimpleIconOption "󰊕 ";
          Variable = mkSimpleIconOption "󰆧 ";
          Constant = mkSimpleIconOption "󰏿 ";
          String = mkSimpleIconOption " ";
          Number = mkSimpleIconOption "󰎠 ";
          Boolean = mkSimpleIconOption "◩ ";
          Array = mkSimpleIconOption "󰅪 ";
          Object = mkSimpleIconOption "󰅩 ";
          Method = mkSimpleIconOption "󰆧 ";
          Key = mkSimpleIconOption "󰌋 ";
          Null = mkSimpleIconOption "󰟢 ";
          EnumMember = mkSimpleIconOption "󰕘 ";
          Struct = mkSimpleIconOption "󰌗 ";
          Event = mkSimpleIconOption " ";
          Operator = mkSimpleIconOption "󰆕 ";
          TypeParameter = mkSimpleIconOption "󰊄 ";
        };
      };
    };
  };
}
