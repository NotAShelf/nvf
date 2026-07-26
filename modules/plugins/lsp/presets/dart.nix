{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.lsp.presets.dart;
in {
  options.vim.lsp.presets.dart = {
    enable = mkLspPresetEnableOption {
      option = "dart";
      display = "Dart";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.dart = {
      enable = true;
      cmd = [(getExe pkgs.dart) "language-server" "--protocol=lsp"];
      root_markers = [".git" "pubspec.yaml"];
      init_options = {
        onlyAnalyzeProjectsWithOpenFiles = true;
        suggestFromUnimportedLibraries = true;
        closingLabels = true;
        outline = true;
        flutterOutline = true;
      };
      settings = {
        dart = {
          completeFunctionCalls = true;
          showTodos = true;
        };
      };
    };
  };
}
