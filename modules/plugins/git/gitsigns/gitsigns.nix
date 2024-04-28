{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkRenamedOptionModule;
  inherit (lib.nvim.binds) mkMappingOption;
in {
  imports = [
    (mkRenamedOptionModule ["vim" "git" "gitsigns" "codeActions" "vim" "gitsigns" "codeActions"] ["vim" "git" "gitsigns" "codeActions" "enable"])
  ];

  options.vim.git.gitsigns = {
    enable = mkEnableOption "gitsigns" // {default = config.vim.git.enable;};

    codeActions.enable = mkEnableOption "gitsigns codeactions through null-ls";

    mappings = {
      nextHunk = mkMappingOption "Next hunk [Gitsigns]" "]c";
      previousHunk = mkMappingOption "Previous hunk [Gitsigns]" "[c";

      stageHunk = mkMappingOption "Stage hunk [Gitsigns]" "<leader>hs";
      undoStageHunk = mkMappingOption "Undo stage hunk [Gitsigns]" "<leader>hu";
      resetHunk = mkMappingOption "Reset hunk [Gitsigns]" "<leader>hr";

      stageBuffer = mkMappingOption "Stage buffer [Gitsigns]" "<leader>hS";
      resetBuffer = mkMappingOption "Reset buffer [Gitsigns]" "<leader>hR";

      previewHunk = mkMappingOption "Preview hunk [Gitsigns]" "<leader>hP";

      blameLine = mkMappingOption "Blame line [Gitsigns]" "<leader>hb";
      toggleBlame = mkMappingOption "Toggle blame [Gitsigns]" "<leader>tb";

      diffThis = mkMappingOption "Diff this [Gitsigns]" "<leader>hd";
      diffProject = mkMappingOption "Diff project [Gitsigns]" "<leader>hD";

      toggleDeleted = mkMappingOption "Toggle deleted [Gitsigns]" "<leader>td";
    };
  };
}
