{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) nullOr listOf enum bool str int;
  inherit (lib.modules) mkRenamedOptionModule;
  inherit (lib.nvim.types) mkPluginSetupOption borderType;
  inherit (config.vim.lib) mkMappingOption;

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
        close = mkMappingOption "Close and return the cursor to its original location." "<esc>";
        nextSibling = mkMappingOption "Navigate to the next sibling node." "j";
        previousSibling = mkMappingOption "Navigate to the previous sibling node." "k";
        parent = mkMappingOption "Navigate to the parent node." "h";
        children = mkMappingOption "Navigate to the child node." "l";
        root = mkMappingOption "Navigate to the root node." "0";
        visualName = mkMappingOption "Select the name visually." "v";
        visualScope = mkMappingOption "Select the scope visually." "V";
        yankName = mkMappingOption "Yank the name to system clipboard." "y";
        yankScope = mkMappingOption "Yank the scope to system clipboard." "Y";
        insertName = mkMappingOption "Insert at the start of name." "i";
        insertScope = mkMappingOption "Insert at the start of scope." "I";
        appendName = mkMappingOption "Insert at the end of name." "a";
        appendScope = mkMappingOption "Insert at the end of scope." "A";
        rename = mkMappingOption "Rename the node." "r";
        delete = mkMappingOption "Delete the node." "d";
        foldCreate = mkMappingOption "Create a new fold of the node." "f";
        foldDelete = mkMappingOption "Delete the current fold of the node." "F";
        comment = mkMappingOption "Comment the node." "c";
        select = mkMappingOption "Goto the node." "<enter>";
        moveDown = mkMappingOption "Move the node down." "J";
        moveUp = mkMappingOption "Move the node up." "K";
        togglePreview = mkMappingOption "Toggle the preview." "s";
        vsplit = mkMappingOption "Open the node in a vertical split." "<C-v>";
        hsplit = mkMappingOption "Open the node in a horizontal split." "<C-s>";
        telescope = mkMappingOption "Start fuzzy finder at the current level." "t";
        help = mkMappingOption "Open the mappings help window." "g?";
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
