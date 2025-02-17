{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.types) int str listOf float bool either enum submodule attrsOf anything package;
  inherit (lib.nvim.binds) mkMappingOption;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline;

  cfg = config.vim.telescope;
  setupOptions = {
    defaults = {
      vimgrep_arguments = mkOption {
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

        description = ''
          Defines the command that will be used for `live_grep` and `grep_string` pickers.
          Make sure that color is set to `never` because telescope does not yet interpret color codes.
        '';
      };

      pickers.find_command = mkOption {
        type = either (listOf str) luaInline;
        default = ["${pkgs.fd}/bin/fd"];
        description = ''
          Command to use for finding files. If using an executable from {env}`PATH` then you must
          make sure that the package is available in [](#opt-vim.extraPackages).
        '';
      };

      prompt_prefix = mkOption {
        type = str;
        default = "     ";
        description = "Shown in front of Telescope's prompt";
      };

      selection_caret = mkOption {
        type = str;
        default = "  ";
        description = "Character(s) to show in front of the current selection";
      };

      entry_prefix = mkOption {
        type = str;
        default = "  ";
        description = "Prefix in front of each result entry. Current selection not included.";
      };

      initial_mode = mkOption {
        type = enum ["insert" "normal"];
        default = "insert";
        description = "Determines in which mode telescope starts.";
      };

      selection_strategy = mkOption {
        type = enum ["reset" "follow" "row" "closest" "none"];
        default = "reset";
        description = "Determines how the cursor acts after each sort iteration.";
      };

      sorting_strategy = mkOption {
        type = enum ["descending" "ascending"];
        default = "ascending";
        description = ''Determines the direction "better" results are sorted towards.'';
      };

      layout_strategy = mkOption {
        type = str;
        default = "horizontal";
        description = "Determines the default layout of Telescope pickers. See `:help telescope.layout`.";
      };

      layout_config = mkOption {
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

        description = ''
          Determines the default configuration values for layout strategies.
          See `telescope.layout` for details of the configurations options for
          each strategy.
        '';
      };

      file_ignore_patterns = mkOption {
        type = listOf str;
        default = ["node_modules" ".git/" "dist/" "build/" "target/" "result/"];
        description = "A table of lua regex that define the files that should be ignored.";
      };

      color_devicons = mkOption {
        type = bool;
        default = true;
        description = "Boolean if devicons should be enabled or not.";
      };

      path_display = mkOption {
        type = listOf (enum ["hidden" "tail" "absolute" "smart" "shorten" "truncate"]);
        default = ["absolute"];
        description = "Determines how file paths are displayed.";
      };

      set_env = mkOption {
        type = attrsOf str;
        default = {COLORTERM = "truecolor";};
        description = "Set an environment for term_previewer";
      };

      winblend = mkOption {
        type = int;
        default = 0;
        description = "pseudo-transparency of keymap hints floating window";
      };

      extensions = mkOption {
        type = attrsOf anything;
        default = builtins.foldl' (acc: x: acc // (x.setup or {})) {} cfg.extensions;
        description = "Attribute set containing per-extension settings for Telescope";
      };
    };
  };

  extensionOpts = {
    options = {
      name = mkOption {
        type = str;
        description = "Name of the extension, will be used to load it with a `require`";
      };

      packages = mkOption {
        type = listOf (either str package);
        default = [];
        description = "Package or packages providing the Telescope extension to be loaded.";
      };

      setup = mkOption {
        type = attrsOf anything;
        default = {};
        example = {fzf = {fuzzy = true;};};
        description = "Named attribute set to be inserted into Telescope's extensions table.";
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

    extensions = mkOption {
      type = listOf (attrsOf (submodule extensionOpts));
      default = [];
      example = literalExpression ''
        [
          {
            name = "fzf";
            packages = [pkgs.vimPlugins.telescope-fzf-native-nvim];
            setup = {fzf = {fuzzy = true;};};
          }
        ]
      '';
      description = ''
        Individual extension configurations containing **name**, **packages** and **setup**
        fields to resolve dependencies, handle `load_extension` calls and add the `setup`
        table into the `extensions` portion of Telescope's setup table.
      '';
    };
  };
}
