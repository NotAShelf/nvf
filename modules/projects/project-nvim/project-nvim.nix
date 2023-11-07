{
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  options.vim.projects.project-nvim = {
    enable = mkEnableOption "project-nvim for project management";

    manualMode = mkOption {
      type = types.bool;
      default = true;
      description = "don't automatically change the root directory so the user has the option to manually do so using `:ProjectRoot` command";
    };

    # detection methods should accept one or more strings from a list
    detectionMethods = mkOption {
      type = types.listOf types.str;
      default = ["lsp" "pattern"];
      description = "Detection methods to use";
    };

    # patterns
    patterns = mkOption {
      type = types.listOf types.str;
      default = [".git" "_darcs" ".hg" ".bzr" ".svn" "Makefile" "package.json" "flake.nix" "cargo.toml"];
      description = "Patterns to use for pattern detection method";
    };

    # table of lsp servers to ignore by name
    lspIgnored = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "LSP servers no ignore by name";
    };

    excludeDirs = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Directories to exclude from project root search";
    };

    showHidden = mkOption {
      type = types.bool;
      default = false;
      description = "Show hidden files in telescope picker";
    };

    silentChdir = mkOption {
      type = types.bool;
      default = true;
      description = "Silently change directory when changing project";
    };

    scopeChdir = mkOption {
      type = types.enum ["global" "tab" "win"];
      default = "global";
      description = "What scope to change the directory";
    };
  };
}
