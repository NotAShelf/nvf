{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) nullOr listOf enum bool str int;
in {
  options.vim.ui.breadcrumbs = {
    enable = mkEnableOption "breadcrumbs";
    source = mkOption {
      type = nullOr (enum ["nvim-navic"]); # TODO: lspsaga and dropbar
      default = "nvim-navic";
      description = ''
        The source to be used for breadcrumbs component. Null means no breadcrumbs.
      '';
    };

    # maybe this should be an option to *disable* alwaysRender optionally but oh well
    # too late
    alwaysRender = mkOption {
      type = bool;
      default = true;
      description = "Whether to always display the breadcrumbs component on winbar (always renders winbar)";
    };

    navbuddy = {
      enable = mkEnableOption "navbuddy LSP helper UI. Enabling this option automatically loads and enables nvim-navic";

      # this option is interpreted as null if mkEnableOption is used, and therefore cannot be converted to a string in config.nix
      useDefaultMappings = mkOption {
        type = bool;
        default = true;
        description = "use default Navbuddy keybindings (disables user-specified keybinds)";
      };

      mappings = {
        close = mkOption {
          type = str;
          default = "<esc>";
          description = "keybinding to close Navbuddy UI";
        };

        nextSibling = mkOption {
          type = str;
          default = "j";
          description = "keybinding to navigate to the next sibling node";
        };

        previousSibling = mkOption {
          type = str;
          default = "k";
          description = "keybinding to navigate to the previous sibling node";
        };

        parent = mkOption {
          type = str;
          default = "h";
          description = "keybinding to navigate to the parent node";
        };

        children = mkOption {
          type = str;
          default = "h";
          description = "keybinding to navigate to the child node";
        };

        root = mkOption {
          type = str;
          default = "0";
          description = "keybinding to navigate to the root node";
        };

        visualName = mkOption {
          type = str;
          default = "v";
          description = "visual selection of name";
        };

        visualScope = mkOption {
          type = str;
          default = "V";
          description = "visual selection of scope";
        };

        yankName = mkOption {
          type = str;
          default = "y";
          description = "yank the name to system clipboard";
        };

        yankScope = mkOption {
          type = str;
          default = "Y";
          description = "yank the scope to system clipboard";
        };

        insertName = mkOption {
          type = str;
          default = "i";
          description = "insert at start of name";
        };

        insertScope = mkOption {
          type = str;
          default = "I";
          description = "insert at start of scope";
        };

        appendName = mkOption {
          type = str;
          default = "a";
          description = "insert at end of name";
        };

        appendScope = mkOption {
          type = str;
          default = "A";
          description = "insert at end of scope";
        };

        rename = mkOption {
          type = str;
          default = "r";
          description = "rename the node";
        };

        delete = mkOption {
          type = str;
          default = "d";
          description = "delete the node";
        };

        foldCreate = mkOption {
          type = str;
          default = "f";
          description = "create a new fold";
        };

        foldDelete = mkOption {
          type = str;
          default = "F";
          description = "delete the current fold";
        };

        comment = mkOption {
          type = str;
          default = "c";
          description = "comment the node";
        };

        select = mkOption {
          type = str;
          default = "<enter>";
          description = "goto selected symbol";
        };

        moveDown = mkOption {
          type = str;
          default = "J";
          description = "move focused node down";
        };

        moveUp = mkOption {
          type = str;
          default = "K";
          description = "move focused node up";
        };

        telescope = mkOption {
          type = str;
          default = "t";
          description = "fuzzy finder at current level";
        };

        help = mkOption {
          type = str;
          default = "g?";
          description = "open mapping help window";
        };
      };

      window = {
        # size = {}
        # position = {}

        border = mkOption {
          # TODO: let this type accept a custom string
          type = enum ["single" "rounded" "double" "solid" "none"];
          default = config.vim.ui.borders.globalStyle;
          description = "border style to use";
        };

        scrolloff = mkOption {
          type = nullOr int;
          default = null;
          description = "Scrolloff value within navbuddy window";
        };

        sections = {
          # left section
          left = {
            /*
            size = {
              type = with types; nullOr (intBetween 0 100);
              default = null;
              description = "size of the left section of Navbuddy UI in percentage (0-100)";
            };
            */

            border = mkOption {
              # TODO: let this type accept a custom string
              type = nullOr (enum ["single" "rounded" "double" "solid" "none"]);
              default = config.vim.ui.borders.globalStyle;
              description = "border style to use for the left section of Navbuddy UI";
            };
          };

          # middle section
          mid = {
            /*
            size = {
              type = with types; nullOr (intBetween 0 100);
              default = null;
              description = "size of the left section of Navbuddy UI in percentage (0-100)";
            };
            */

            border = mkOption {
              # TODO: let this type accept a custom string
              type = nullOr (enum ["single" "rounded" "double" "solid" "none"]);
              default = config.vim.ui.borders.globalStyle;
              description = "border style to use for the middle section of Navbuddy UI";
            };
          };

          # right section
          # there is no size option for the right section, it fills the remaining space
          right = {
            border = mkOption {
              # TODO: let this type accept a custom string
              type = nullOr (enum ["single" "rounded" "double" "solid" "none"]);
              default = config.vim.ui.borders.globalStyle;
              description = "border style to use for the right section of Navbuddy UI";
            };

            preview = mkOption {
              type = enum ["leaf" "always" "never"];
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
            type = str;
            default = "  ";
            description = "";
          };

          leafSelected = mkOption {
            type = str;
            default = " → ";
            description = "";
          };

          branch = mkOption {
            type = str;
            default = " ";
            description = "";
          };
        };
      };

      lsp = {
        autoAttach = mkOption {
          type = bool;
          default = true;
          description = "Whether to attach to LSP server manually";
        };

        preference = mkOption {
          type = nullOr (listOf str);
          default = null;
          description = "list of lsp server names in order of preference";
        };
      };

      sourceBuffer = {
        followNode = mkOption {
          type = bool;
          default = true;
          description = "keep the current node in focus on the source buffer";
        };

        highlight = mkOption {
          type = bool;
          default = true;
          description = "highlight the currently focused node";
        };

        reorient = mkOption {
          type = enum ["smart" "top" "mid" "none"];
          default = "smart";
          description = "reorient buffer after changing nodes";
        };

        scrolloff = mkOption {
          type = nullOr int;
          default = null;
          description = "scrolloff value when navbuddy is open";
        };
      };

      # there probably is a better way to do this
      # alas, I am not a nix wizard
      icons = {
        file = mkOption {
          type = str;
          default = "󰈙 ";
          description = "File icon";
        };

        module = mkOption {
          type = str;
          default = " ";
          description = "Module icon";
        };

        namespace = mkOption {
          type = str;
          default = "󰌗 ";
          description = "Namespace icon";
        };

        package = mkOption {
          type = str;
          default = " ";
          description = "";
        };

        class = mkOption {
          type = str;
          default = "󰌗 ";
          description = "Class icon";
        };

        property = mkOption {
          type = str;
          default = " ";
          description = "";
        };

        field = mkOption {
          type = str;
          default = " ";
          description = "Field icon";
        };

        constructor = mkOption {
          type = str;
          default = " ";
          description = "Constructor icon";
        };

        enum = mkOption {
          type = str;
          default = "󰕘";
          description = "Enum icon";
        };

        interface = mkOption {
          type = str;
          default = "󰕘";
          description = "Interface icon";
        };

        function = mkOption {
          type = str;
          default = "󰊕 ";
          description = "Function icon";
        };

        variable = mkOption {
          type = str;
          default = "󰆧 ";
          description = "";
        };

        constant = mkOption {
          type = str;
          default = "󰏿 ";
          description = "Constant icon";
        };

        string = mkOption {
          type = str;
          default = " ";
          description = "";
        };

        number = mkOption {
          type = str;
          default = "󰎠 ";
          description = "Number icon";
        };

        boolean = mkOption {
          type = str;
          default = "◩ ";
          description = "";
        };

        array = mkOption {
          type = str;
          default = "󰅪 ";
          description = "Array icon";
        };

        object = mkOption {
          type = str;
          default = "󰅩 ";
          description = "Object icon";
        };

        method = mkOption {
          type = str;
          default = "󰆧 ";
          description = "Method icon";
        };

        key = mkOption {
          type = str;
          default = "󰌋 ";
          description = "Key icon";
        };

        null = mkOption {
          type = str;
          default = "󰟢 ";
          description = "Null icon";
        };

        enumMember = mkOption {
          type = str;
          default = "󰕘 ";
          description = "Enum member icon";
        };

        struct = mkOption {
          type = str;
          default = "󰌗 ";
          description = "Struct icon";
        };

        event = mkOption {
          type = str;
          default = " ";
          description = "Event icon";
        };

        operator = mkOption {
          type = str;
          default = "󰆕 ";
          description = "Operator icon";
        };

        typeParameter = mkOption {
          type = str;
          default = "󰊄 ";
          description = "Type parameter icon";
        };
      };
    };
  };
}
