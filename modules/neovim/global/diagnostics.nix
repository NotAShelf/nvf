{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) str bool enum either;
in {
  options.vim.diagnostics = {
    virtual_text = mkOption {
      type = bool;
      default = true;
      description = ''
        Whether to use virtual text for diagnostics.

        If multiple diagnostics are set for a namespace, one
        prefix per diagnostic + the last diagnostic message
        are shown.
      '';
    };

    update_in_insert = mkOption {
      type = bool;
      default = false;
      description = ''
        Whether to update diagnostics in insert mode.

        This is useful for slow diagnostics sources, but can
        also cause lag in insert mode.
      '';
    };

    underline = mkOption {
      type = bool;
      default = true;
      description = ''
        Whether to underline diagnostics.
      '';
    };

    severity_sort = mkOption {
      type = bool;
      default = false;
      description = ''
        Whether to sort diagnostics by severity.

        This affects the order in which signs and
        virtual text are displayed. When true, higher
        severities are displayed before lower severities (e.g.
        ERROR is displayed before WARN)
      '';
    };

    float = {
      focusable = mkOption {
        type = bool;
        default = false;
        description = ''
          Whether the floating window is focusable.
          When true, the floating window can be focused and
          interacted with. When false, the floating window is
          not focusable and will not receive input.
        '';
      };

      border = mkOption {
        type = enum ["none" "single" "double" "rounded" "solid" "shadow"];
        default = config.vim.ui.border.globalStyle;
        description = ''
          The border style of the floating window.

          Possible values:
            - none
            - single
            - double
            - rounded
            - solid
            - shadow

          See `:h nvim_open_win` for the available border
          styles and their definitions.
        '';
      };

      source = mkOption {
        type = either bool (enum ["always" "if_many"]);
        default = "auto";
        description = ''
            The source of the floating window.
            Possible values:
          - auto: Use the same source as the diagnostics
            window.
          - window: Use the window source.
          - buffer: Use the buffer source.
        '';
      };

      prefix = mkOption {
        type = str;
        default = "";
        description = ''
          Prefix string for each diagnostic in the floating window
        '';
      };

      suffix = mkOption {
        type = str;
        default = "";
        description = ''
          Suffix string for each diagnostic in the floating window
        '';
      };
    };
  };
}
