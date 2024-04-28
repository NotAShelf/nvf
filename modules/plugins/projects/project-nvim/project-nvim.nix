{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkRenamedOptionModule;
  inherit (lib.types) bool listOf str enum;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  imports = let
    renamedSetupOption = oldPath: newPath:
      mkRenamedOptionModule
      (["vim" "projects" "project-nvim"] ++ oldPath)
      (["vim" "projects" "project-nvim" "setupOpts"] ++ newPath);
  in [
    (renamedSetupOption ["manualMode"] ["manual_mode"])
    (renamedSetupOption ["detectionMethods"] ["detection_methods"])
    (renamedSetupOption ["patterns"] ["patterns"])
    (renamedSetupOption ["lspIgnored"] ["lsp_ignored"])
    (renamedSetupOption ["excludeDirs"] ["exclude_dirs"])
    (renamedSetupOption ["showHidden"] ["show_hidden"])
    (renamedSetupOption ["silentChdir"] ["silent_chdir"])
    (renamedSetupOption ["scopeChdir"] ["scope_chdir"])
  ];

  options.vim.projects.project-nvim = {
    enable = mkEnableOption "project-nvim for project management";

    setupOpts = mkPluginSetupOption "Project.nvim" {
      manual_mode = mkOption {
        type = bool;
        default = true;
        description = "don't automatically change the root directory so the user has the option to manually do so using `:ProjectRoot` command";
      };

      # detection methods should accept one or more strings from a list
      detection_methods = mkOption {
        type = listOf str;
        default = ["lsp" "pattern"];
        description = "Detection methods to use";
      };

      # patterns
      patterns = mkOption {
        type = listOf str;
        default = [".git" "_darcs" ".hg" ".bzr" ".svn" "Makefile" "package.json" "flake.nix" "cargo.toml"];
        description = "Patterns to use for pattern detection method";
      };

      # table of lsp servers to ignore by name
      lsp_ignored = mkOption {
        type = listOf str;
        default = [];
        description = "LSP servers no ignore by name";
      };

      exclude_dirs = mkOption {
        type = listOf str;
        default = [];
        description = "Directories to exclude from project root search";
      };

      show_hidden = mkOption {
        type = bool;
        default = false;
        description = "Show hidden files in telescope picker";
      };

      silent_chdir = mkOption {
        type = bool;
        default = true;
        description = "Silently change directory when changing project";
      };

      scope_chdir = mkOption {
        type = enum ["global" "tab" "win"];
        default = "global";
        description = "What scope to change the directory";
      };
    };
  };
}
