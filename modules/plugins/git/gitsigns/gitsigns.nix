{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkRenamedOptionModule;
  inherit (lib.nvim.binds) mkMappingOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  imports = [
    (mkRenamedOptionModule ["vim" "git" "gitsigns" "codeActions" "vim" "gitsigns" "codeActions"] ["vim" "git" "gitsigns" "codeActions" "enable"])
  ];

  options.vim.git.gitsigns = {
    enable = mkEnableOption "gitsigns" // {default = config.vim.git.enable;};
    setupOpts = mkPluginSetupOption "gitsigns" {};

    codeActions.enable = mkEnableOption "gitsigns codeactions through null-ls";

    mappings = {
      nextHunk = mkMappingOption config.vim.enableNvfKeymaps "Next hunk [Gitsigns]" "]c";
      previousHunk = mkMappingOption config.vim.enableNvfKeymaps "Previous hunk [Gitsigns]" "[c";

      stageHunk = mkMappingOption config.vim.enableNvfKeymaps "Stage hunk [Gitsigns]" "<leader>hs";
      undoStageHunk = mkMappingOption config.vim.enableNvfKeymaps "Undo stage hunk [Gitsigns]" "<leader>hu";
      resetHunk = mkMappingOption config.vim.enableNvfKeymaps "Reset hunk [Gitsigns]" "<leader>hr";

      stageBuffer = mkMappingOption config.vim.enableNvfKeymaps "Stage buffer [Gitsigns]" "<leader>hS";
      resetBuffer = mkMappingOption config.vim.enableNvfKeymaps "Reset buffer [Gitsigns]" "<leader>hR";

      previewHunk = mkMappingOption config.vim.enableNvfKeymaps "Preview hunk [Gitsigns]" "<leader>hP";

      blameLine = mkMappingOption config.vim.enableNvfKeymaps "Blame line [Gitsigns]" "<leader>hb";
      toggleBlame = mkMappingOption config.vim.enableNvfKeymaps "Toggle blame [Gitsigns]" "<leader>tb";

      diffThis = mkMappingOption config.vim.enableNvfKeymaps "Diff this [Gitsigns]" "<leader>hd";
      diffProject = mkMappingOption config.vim.enableNvfKeymaps "Diff project [Gitsigns]" "<leader>hD";

      toggleDeleted = mkMappingOption config.vim.enableNvfKeymaps "Toggle deleted [Gitsigns]" "<leader>td";
    };
  };
}
