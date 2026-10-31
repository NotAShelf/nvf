{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
  mkMappingOption = config.vim.lib.mkMappingOption "Gitsigns";
in {
  options.vim.git.gitsigns = {
    enable = mkEnableOption "gitsigns" // {default = config.vim.git.enable;};
    setupOpts = mkPluginSetupOption "gitsigns" {};

    codeActions.enable = mkEnableOption "gitsigns codeactions through null-ls";

    mappings = {
      nextHunk = mkMappingOption "Next hunk" "]c";
      previousHunk = mkMappingOption "Previous hunk" "[c";

      stageHunk = mkMappingOption "Stage hunk" "<leader>hs";
      undoStageHunk = mkMappingOption "Undo stage hunk" "<leader>hu";
      resetHunk = mkMappingOption "Reset hunk" "<leader>hr";

      stageBuffer = mkMappingOption "Stage buffer" "<leader>hS";
      resetBuffer = mkMappingOption "Reset buffer" "<leader>hR";

      previewHunk = mkMappingOption "Preview hunk" "<leader>hP";

      blameLine = mkMappingOption "Blame line" "<leader>hb";
      toggleBlame = mkMappingOption "Toggle blame" "<leader>tb";

      diffThis = mkMappingOption "Diff this" "<leader>hd";
      diffProject = mkMappingOption "Diff project" "<leader>hD";

      toggleDeleted = mkMappingOption "Toggle deleted" "<leader>td";
    };
  };
}
