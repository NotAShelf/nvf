{lib, ...}: let
  inherit
    (lib.types)
    nullOr
    str
    bool
    int
    attrsOf
    listOf
    enum
    ;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline;
  inherit (lib.nvim.binds) mkMappingOption;
in {
  options.vim.assistant.neocodeium = {
    enable = mkEnableOption "NeoCodeium AI completion";

    setupOpts = mkPluginSetupOption "NeoCodeium" {
      enabled = mkOption {
        type = nullOr bool;
        default = null;
        description = "Whether to start windsurf server. Can be manually enabled with `:NeoCodeium enable`";
      };

      bin = mkOption {
        type = nullOr str;
        default = null;
        description = "Path to custom windsurf server binary";
      };

      manual = mkOption {
        type = nullOr bool;
        default = null;
        description = "When true, autosuggestions are disabled. Use `require'neocodeium'.cycle_or_complete()` to show suggestions manually";
      };

      server = {
        api_url = mkOption {
          type = nullOr str;
          default = null;
          description = "API URL to use (for Enterprise mode)";
        };
        portal_url = mkOption {
          type = nullOr str;
          default = null;
          description = "Portal URL to use (for registering a user and downloading the binary)";
        };
      };

      show_label = mkOption {
        type = nullOr bool;
        default = null;
        description = "Whether to show the number of suggestions label in the line number column";
      };

      debounce = mkOption {
        type = nullOr bool;
        default = null;
        description = "Whether to enable suggestions debounce";
      };

      max_lines = mkOption {
        type = nullOr int;
        default = null;
        example = 10000;
        description = ''
          Maximum number of lines parsed from loaded buffers (current buffer always fully parsed).
          Set to `0` to disable parsing non-current buffers.
          Set to `-1` to parse all lines
        '';
      };

      silent = mkOption {
        type = nullOr bool;
        default = null;
        description = "Whether to disable non-important messages";
      };

      disable_in_special_buftypes = mkOption {
        type = nullOr bool;
        default = null;
        description = "Whether to disable suggestions in special buftypes like `nofile`";
      };

      log_level = mkOption {
        type = nullOr (enum [
          "trace"
          "debug"
          "info"
          "warn"
          "error"
        ]);
        default = null;
        example = "warn";
        description = "Log level";
      };

      single_line = {
        enabled = mkOption {
          type = nullOr bool;
          default = null;
          description = "Whether to enable single line mode. Multi-line suggestions collapse into a single line";
        };
        label = mkOption {
          type = nullOr str;
          default = null;
          example = "...";
          description = "Label indicating that there is multi-line suggestion";
        };
      };

      filter = mkOption {
        type = nullOr luaInline;
        default = null;
        description = ''
          Function that returns `true` if a buffer should be enabled and `false` if disabled.
          You can still enable disabled buffer with `:NeoCodeium enable_buffer`
        '';
      };

      filetypes = mkOption {
        type = nullOr (attrsOf bool);
        default = null;
        example = {
          help = false;
          gitcommit = false;
        };
        description = ''
          Filetypes to disable suggestions in.
          You can still enable disabled buffer with `:NeoCodeium enable_buffer`
        '';
      };

      root_dir = mkOption {
        type = nullOr (listOf str);
        default = null;
        example = [
          ".git"
          "package.json"
        ];
        description = "List of directories and files to detect workspace root directory for Windsurf Chat";
      };
    };

    keymaps = {
      accept = mkMappingOption "Accept suggestion" "<A-f>";
      accept_word = mkMappingOption "Accept word" "<A-w>";
      accept_line = mkMappingOption "Accept line" "<A-a>";
      cycle_or_complete = mkMappingOption "Cycle or complete" "<A-e>";
      cycle_or_complete_reverse = mkMappingOption "Cycle or complete (reverse)" "<A-r>";
      clear = mkMappingOption "Clear suggestion" "<A-c>";
    };
  };
}
