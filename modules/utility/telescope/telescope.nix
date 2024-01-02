{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) int str listOf float bool;
  inherit (lib.nvim.binds) mkMappingOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
  mkOptOfType = type: default:
    mkOption {
      # TODO: description
      description = "See plugin docs for more info";
      inherit type default;
    };

  setupOptions = {
    defaults = {
      vimgrep_arguments = mkOptOfType (listOf str) [
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
      pickers.find_command = mkOptOfType (listOf str) ["${pkgs.fd}/bin/fd"];
      prompt_prefix = mkOptOfType str "     ";
      selection_caret = mkOptOfType str "  ";
      entry_prefix = mkOptOfType str "  ";
      initial_mode = mkOptOfType str "insert";
      selection_strategy = mkOptOfType str "reset";
      sorting_strategy = mkOptOfType str "ascending";
      layout_strategy = mkOptOfType str "horizontal";
      layout_config = {
        horizontal = {
          prompt_position = mkOptOfType str "top";
          preview_width = mkOptOfType float 0.55;
          results_width = mkOptOfType float 0.8;
        };
        vertical = {
          mirror = mkOptOfType bool false;
        };
        width = mkOptOfType float 0.8;
        height = mkOptOfType float 0.8;
        preview_cutoff = mkOptOfType int 120;
      };
      file_ignore_patterns = mkOptOfType (listOf str) ["node_modules" ".git/" "dist/" "build/" "target/" "result/"];
      color_devicons = mkOptOfType bool true;
      path_display = mkOptOfType (listOf str) ["absolute"];
      set_env = {
        COLORTERM = mkOptOfType str "truecolor";
      };
      winblend = mkOptOfType int 0;
    };
  };
in {
  options.vim.telescope = {
    mappings = {
      findProjects = mkMappingOption "Find files [Telescope]" "<leader>fp";

      findFiles = mkMappingOption "Find files [Telescope]" "<leader>ff";
      liveGrep = mkMappingOption "Live grep [Telescope]" "<leader>fg";
      buffers = mkMappingOption "Buffers [Telescope]" "<leader>fb";
      helpTags = mkMappingOption "Help tags [Telescope]" "<leader>fh";
      open = mkMappingOption "Open [Telescope]" "<leader>ft";

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
