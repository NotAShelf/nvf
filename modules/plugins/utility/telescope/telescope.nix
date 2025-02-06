{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) int str listOf float bool either enum submodule attrsOf;
  inherit (lib.nvim.binds) mkMappingOption;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline;
  setupOptions = {
    defaults = {
      vimgrep_arguments = mkOption {
        description = ''
          Defines the command that will be used for `live_grep` and `grep_string` pickers.
          Make sure that color is set to `never` because telescope does not yet interpret color codes.
        '';
        type = listOf str;
        default = [
          "${pkgs.ripgrep}/bin/rg"
          "--color=never"
          "--no-heading"
          "--with-filename"
          "--line-number"
          "--column"
          "--smart-case"
          "--hidden"
          "--no-ignore"
        ];
      };
      pickers.find_command = mkOption {
        description = "cmd to use for finding files";
        type = either (listOf str) luaInline;
        default = ["${pkgs.fd}/bin/fd"];
      };
      prompt_prefix = mkOption {
        description = "Shown in front of Telescope's prompt";
        type = str;
        default = "     ";
      };
      selection_caret = mkOption {
        description = "Character(s) to show in front of the current selection";
        type = str;
        default = "  ";
      };
      entry_prefix = mkOption {
        description = "Prefix in front of each result entry. Current selection not included.";
        type = str;
        default = "  ";
      };
      initial_mode = mkOption {
        description = "Determines in which mode telescope starts.";
        type = enum ["insert" "normal"];
        default = "insert";
      };
      selection_strategy = mkOption {
        description = "Determines how the cursor acts after each sort iteration.";
        type = enum ["reset" "follow" "row" "closest" "none"];
        default = "reset";
      };
      sorting_strategy = mkOption {
        description = ''Determines the direction "better" results are sorted towards.'';
        type = enum ["descending" "ascending"];
        default = "ascending";
      };
      layout_strategy = mkOption {
        description = "Determines the default layout of Telescope pickers. See `:help telescope.layout`.";
        type = str;
        default = "horizontal";
      };
      layout_config = mkOption {
        description = ''
          Determines the default configuration values for layout strategies.
          See telescope.layout for details of the configurations options for
          each strategy.
        '';
        default = {};
        type = submodule {
          options = {
            horizontal = {
              prompt_position = mkOption {
                description = "";
                type = str;
                default = "top";
              };
              preview_width = mkOption {
                description = "";
                type = float;
                default = 0.55;
              };
            };
            vertical = {
              mirror = mkOption {
                description = "";
                type = bool;
                default = false;
              };
            };
            width = mkOption {
              description = "";
              type = float;
              default = 0.8;
            };
            height = mkOption {
              description = "";
              type = float;
              default = 0.8;
            };
            preview_cutoff = mkOption {
              description = "";
              type = int;
              default = 120;
            };
          };
        };
      };
      file_ignore_patterns = mkOption {
        description = "A table of lua regex that define the files that should be ignored.";
        type = listOf str;
        default = ["node_modules" ".git/" "dist/" "build/" "target/" "result/"];
      };
      color_devicons = mkOption {
        description = "Boolean if devicons should be enabled or not.";
        type = bool;
        default = true;
      };
      path_display = mkOption {
        description = "Determines how file paths are displayed.";
        type = listOf (enum ["hidden" "tail" "absolute" "smart" "shorten" "truncate"]);
        default = ["absolute"];
      };
      set_env = mkOption {
        description = "Set an environment for term_previewer";
        type = attrsOf str;
        default = {
          COLORTERM = "truecolor";
        };
      };
      winblend = mkOption {
        description = "pseudo-transparency of keymap hints floating window";
        type = int;
        default = 0;
      };
    };
  };
in {
  options.vim.telescope = {
    mappings = {
      findProjects = mkMappingOption "Find projects [Telescope]" "<leader>fp";
      findFiles = mkMappingOption "Find files [Telescope]" "<leader>ff";
      liveGrep = mkMappingOption "Live grep [Telescope]" "<leader>fg";
      buffers = mkMappingOption "Buffers [Telescope]" "<leader>fb";
      helpTags = mkMappingOption "Help tags [Telescope]" "<leader>fh";
      open = mkMappingOption "Open [Telescope]" "<leader>ft";
      resume = mkMappingOption "Resume (previous search) [Telescope]" "<leader>fr";

      gitCommits = mkMappingOption "Git commits [Telescope]" "<leader>fvcw";
      gitBufferCommits = mkMappingOption "Git buffer commits [Telescope]" "<leader>fvcb";
      gitBranches = mkMappingOption "Git branches [Telescope]" "<leader>fvb";
      gitStatus = mkMappingOption "Git status [Telescope]" "<leader>fvs";
      gitStash = mkMappingOption "Git stash [Telescope]" "<leader>fvx";

      lspDocumentSymbols = mkMappingOption "LSP Document Symbols [Telescope]" "<leader>flsb";
      lspWorkspaceSymbols = mkMappingOption "LSP Workspace Symbols [Telescope]" "<leader>flsw";
      lspReferences = mkMappingOption "LSP References [Telescope]" "<leader>flr";
      lspImplementations = mkMappingOption "LSP Implementations [Telescope]" "<leader>fli";
      lspDefinitions = mkMappingOption "LSP Definitions [Telescope]" "<leader>flD";
      lspTypeDefinitions = mkMappingOption "LSP Type Definitions [Telescope]" "<leader>flt";
      diagnostics = mkMappingOption "Diagnostics [Telescope]" "<leader>fld";

      treesitter = mkMappingOption "Treesitter [Telescope]" "<leader>fs";
    };

    enable = mkEnableOption "telescope.nvim: multi-purpose search and picker utility";

    setupOpts = mkPluginSetupOption "Telescope" setupOptions;
  };
}
