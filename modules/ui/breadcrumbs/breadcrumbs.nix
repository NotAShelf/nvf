{
  lib,
  config,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  options.vim.ui.breadcrumbs = {
    enable = lib.mkEnableOption "breadcrumbs";
    source = mkOption {
      type = with types; nullOr (enum ["nvim-navic"]); # TODO: lspsaga and dropbar
      default = "nvim-navic";
      description = ''
        The source to be used for breadcrumbs component. Null means no breadcrumbs.
      '';
    };

    # maybe this should be an option to *disable* alwaysRender optionally but oh well
    # too late
    alwaysRender = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to always display the breadcrumbs component on winbar (always renders winbar)";
    };

    navbuddy = {
      enable = mkEnableOption "navbuddy LSP helper UI. Enabling this option automatically loads and enables nvim-navic";

      # this option is interpreted as null if mkEnableOption is used, and therefore cannot be converted to a string in config.nix
      useDefaultMappings = mkOption {
        type = types.bool;
        default = true;
        description = "use default Navbuddy keybindings (disables user-specified keybinds)";
      };

      mappings = {
        close = mkOption {
          type = types.str;
          default = "<esc>";
          description = "keybinding to close Navbuddy UI";
        };

        nextSibling = mkOption {
          type = types.str;
          default = "j";
          description = "keybinding to navigate to the next sibling node";
        };

        previousSibling = mkOption {
          type = types.str;
          default = "k";
          description = "keybinding to navigate to the previous sibling node";
        };

        parent = mkOption {
          type = types.str;
          default = "h";
          description = "keybinding to navigate to the parent node";
        };

        children = mkOption {
          type = types.str;
          default = "h";
          description = "keybinding to navigate to the child node";
        };

        root = mkOption {
          type = types.str;
          default = "0";
          description = "keybinding to navigate to the root node";
        };

        visualName = mkOption {
          type = types.str;
          default = "v";
          description = "visual selection of name";
        };

        visualScope = mkOption {
          type = types.str;
          default = "V";
          description = "visual selection of scope";
        };

        yankName = mkOption {
          type = types.str;
          default = "y";
          description = "yank the name to system clipboard";
        };

        yankScope = mkOption {
          type = types.str;
          default = "Y";
          description = "yank the scope to system clipboard";
        };

        insertName = mkOption {
          type = types.str;
          default = "i";
          description = "insert at start of name";
        };

        insertScope = mkOption {
          type = types.str;
          default = "I";
          description = "insert at start of scope";
        };

        appendName = mkOption {
          type = types.str;
          default = "a";
          description = "insert at end of name";
        };

        appendScope = mkOption {
          type = types.str;
          default = "A";
          description = "insert at end of scope";
        };

        rename = mkOption {
          type = types.str;
          default = "r";
          description = "rename the node";
        };

        delete = mkOption {
          type = types.str;
          default = "d";
          description = "delete the node";
        };

        foldCreate = mkOption {
          type = types.str;
          default = "f";
          description = "create a new fold";
        };

        foldDelete = mkOption {
          type = types.str;
          default = "F";
          description = "delete the current fold";
        };

        comment = mkOption {
          type = types.str;
          default = "c";
          description = "comment the node";
        };

        select = mkOption {
          type = types.str;
          default = "<enter>";
          description = "goto selected symbol";
        };

        moveDown = mkOption {
          type = types.str;
          default = "J";
          description = "move focused node down";
        };

        moveUp = mkOption {
          type = types.str;
          default = "K";
          description = "move focused node up";
        };

        telescope = mkOption {
          type = types.str;
          default = "t";
          description = "fuzzy finder at current level";
        };

        help = mkOption {
          type = types.str;
          default = "g?";
          description = "open mapping help window";
        };
      };

      window = {
        # size = {}
        # position = {}

        border = mkOption {
          # TODO: let this type accept a custom string
          type = types.enum ["single" "rounded" "double" "solid" "none"];
          default = config.vim.ui.borders.globalStyle;
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
            /*
            size = {
              type = with types; nullOr (intBetween 0 100);
              default = null;
              description = "size of the left section of Navbuddy UI in percentage (0-100)";
            };
            */

            border = mkOption {
              # TODO: let this type accept a custom string
              type = with types; nullOr (enum ["single" "rounded" "double" "solid" "none"]);
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
              type = with types; nullOr (enum ["single" "rounded" "double" "solid" "none"]);
              default = config.vim.ui.borders.globalStyle;
              description = "border style to use for the middle section of Navbuddy UI";
            };
          };

          # right section
          # there is no size option for the right section, it fills the remaining space
          right = {
            border = mkOption {
              # TODO: let this type accept a custom string
              type = with types; nullOr (enum ["single" "rounded" "double" "solid" "none"]);
              default = config.vim.ui.borders.globalStyle;
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
          description = "reorient buffer after changing nodes";
        };

        scrolloff = mkOption {
          type = with types; nullOr int;
          default = null;
          description = "scrolloff value when navbuddy is open";
        };
      };

      # there probably is a better way to do this
      # alas, I am not a nix wizard
      icons = {
        file = mkOption {
          type = types.str;
          default = "󰈙 ";
          description = "";
        };

        module = mkOption {
          type = types.str;
          default = " ";
          description = "";
        };

        namespace = mkOption {
          type = types.str;
          default = "󰌗 ";
          description = "";
        };

        package = mkOption {
          type = types.str;
          default = " ";
          description = "";
        };

        class = mkOption {
          type = types.str;
          default = "󰌗 ";
          description = "";
        };

        property = mkOption {
          type = types.str;
          default = " ";
          description = "";
        };

        field = mkOption {
          type = types.str;
          default = " ";
          description = "";
        };

        constructor = mkOption {
          type = types.str;
          default = " ";
          description = "";
        };

        enum = mkOption {
          type = types.str;
          default = "󰕘";
          description = "";
        };

        interface = mkOption {
          type = types.str;
          default = "󰕘";
          description = "";
        };

        function = mkOption {
          type = types.str;
          default = "󰊕 ";
          description = "";
        };

        variable = mkOption {
          type = types.str;
          default = "󰆧 ";
          description = "";
        };

        constant = mkOption {
          type = types.str;
          default = "󰏿 ";
          description = "";
        };

        string = mkOption {
          type = types.str;
          default = " ";
          description = "";
        };

        number = mkOption {
          type = types.str;
          default = "󰎠 ";
          description = "";
        };

        boolean = mkOption {
          type = types.str;
          default = "◩ ";
          description = "";
        };

        array = mkOption {
          type = types.str;
          default = "󰅪 ";
          description = "";
        };

        object = mkOption {
          type = types.str;
          default = "󰅩 ";
          description = "";
        };

        method = mkOption {
          type = types.str;
          default = "󰆧 ";
          description = "";
        };

        key = mkOption {
          type = types.str;
          default = "󰌋 ";
          description = "";
        };

        null = mkOption {
          type = types.str;
          default = "󰟢 ";
          description = "";
        };

        enumMember = mkOption {
          type = types.str;
          default = "󰕘 ";
          description = "";
        };

        struct = mkOption {
          type = types.str;
          default = "󰌗 ";
          description = "";
        };

        event = mkOption {
          type = types.str;
          default = " ";
          description = "";
        };

        operator = mkOption {
          type = types.str;
          default = "󰆕 ";
          description = "";
        };

        typeParameter = mkOption {
          type = types.str;
          default = "󰊄 ";
          description = "";
        };
      };
    };
  };
}
