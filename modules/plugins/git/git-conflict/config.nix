{
  config,
  lib,
  options,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.binds) mkKeymap;

  cfg = config.vim.git.git-conflict;

  inherit (options.vim.git.git-conflict) mappings;
in {
  config = mkIf cfg.enable {
    vim.lazy.plugins.git-conflict-nvim = {
      package = "git-conflict-nvim";
      setupModule = "git-conflict";
      setupOpts = {default_mappings = false;} // cfg.setupOpts;
      event = ["BufReadPre" "BufNewFile"];
      cmd = [
        "GitConflictRefresh"
        "GitConflictListQf"
        "GitConflictChooseOurs"
        "GitConflictChooseTheirs"
        "GitConflictChooseBoth"
        "GitConflictChooseBase"
        "GitConflictChooseNone"
        "GitConflictNextConflict"
        "GitConflictPrevConflict"
      ];
      keys = [
        (mkKeymap "n" cfg.mappings.ours "<Plug>(git-conflict-ours)" {desc = mappings.ours.description;})
        (mkKeymap "n" cfg.mappings.theirs "<Plug>(git-conflict-theirs)" {desc = mappings.theirs.description;})
        (mkKeymap "n" cfg.mappings.both "<Plug>(git-conflict-both)" {desc = mappings.both.description;})
        (mkKeymap "n" cfg.mappings.none "<Plug>(git-conflict-none)" {desc = mappings.none.description;})
        (mkKeymap "n" cfg.mappings.prevConflict "<Plug>(git-conflict-prev-conflict)" {desc = mappings.prevConflict.description;})
        (mkKeymap "n" cfg.mappings.nextConflict "<Plug>(git-conflict-next-conflict)" {desc = mappings.nextConflict.description;})
      ];
    };
  };
}
