{lib, ...}: let
  inherit (lib.types) bool str enum either listOf;
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.filetree.neo-tree = {
    enable = mkEnableOption "filetree via neo-tree.nvim";

    # Permalink:
    # https://github.com/nvim-neo-tree/neo-tree.nvim/blob/22e566aeb075c94f670f34077e05ba95190dfb4a/lua/neo-tree/defaults.lua
    setupOpts = mkPluginSetupOption "neo-tree" {
      add_blank_line_at_top = mkOption {
        type = bool;
        default = false;
        description = ''
          Whether to add a blank line at the top of the tree
        '';
      };

      auto_clean_after_session_restore = mkOption {
        type = bool;
        default = false;
        description = ''
          Whether to automatically clean up broken neo-tree buffers
          saved in sessions
        '';
      };

      default_source = mkOption {
        type = str;
        default = "filesystem";
        description = ''
          You can choose a specific source.

          `last` here which indicates the last used source
        '';
      };

      enable_diagnostics = mkEnableOption "diagnostics" // {default = true;};
      enable_git_status = mkEnableOption "git status" // {default = true;};
      enable_modified_markers = mkEnableOption "markers for files with unsaved changes." // {default = true;};
      enable_opened_markers =
        mkEnableOption ''
          tracking of opened files.

          Required for `components.name.highlight_opened_files`
        ''
        // {default = true;};

      enable_refresh_on_write =
        mkEnableOption ''
          Refresh the tree when a file is written.

          Only used if `use_libuv_file_watcher` is false.
        ''
        // {default = true;};

      enable_cursor_hijack = mkEnableOption ''
        cursor hijacking.

        If enabled neotree will keep the cursor on the first letter of the filename when moving in the tree
      '';

      git_status_async = mkEnableOption ''
        async git status.

        This will make the git status check async and will not block the UI.
      '';

      /*
      git_status_async_options = mkOption {
        description = "These options are for people with VERY large git repos";
        type = submodule {
          batch_size = mkOption {
            type = int;
            default = 1000;
            description = "How many lines of git status results to process at a time";
          };

          batch_delay = mkOption {
            type = int;
            default = 10;
            description = "Delay, in ms, between batches. Spreads out the workload to let other processes run";
          };

          max_lines = mkOption {
            type = int;
            default = 10000;
            description = ''
              How many lines of git status results to process.

              Anything after this will be dropped. Anything before this will be used.
              The last items to be processed are the untracked files.
            '';
          };
        };
      };
      */

      hide_root_node = mkOption {
        type = bool;
        default = false;
        description = ''
          Whether to hide the root node of the tree
        '';
      };

      retain_hidden_root_indent = mkOption {
        type = bool;
        default = false;
        description = ''
          Whether to retain the indent of the hidden root node

          IF the root node is hidden, keep the indentation anyhow.
          This is needed if you use expanders because they render in the indent.
        '';
      };

      log_level = mkOption {
        type = enum ["trace" "debug" "info" "warn" "error" "fatal"];
        default = "info";
        description = "Log level for the plugin.";
      };

      log_to_file = mkOption {
        type = either bool str;
        default = false;
        example = literalExpression "/tmp/neo-tree.log";
        description = ''
          Must be either a boolean or a path to your log file.

          Use :NeoTreeLogs to show the file
        '';
      };

      open_files_in_last_window = mkOption {
        type = bool;
        default = true;
        description = ''
          Whether to open files in the last window

          If disabled, neo-tree will open files in top left window
        '';
      };

      open_files_do_not_replace_types = mkOption {
        type = listOf str;
        default = ["terminal" "Trouble" "qf" "edgy"];
        description = ''
          A list of filetypes that should not be replaced when opening a file
        '';
      };

      filesystem = {
        hijack_netrw_behavior = mkOption {
          type = enum ["disabled" "open_default" "open_current"];
          default = "open_default";
          description = "Hijack Netrw behavior";
        };
      };
    };
  };
}
