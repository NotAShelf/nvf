{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.texlab;
in {
  options.vim.lsp.presets.texlab = {
    enable = mkLspPresetEnableOption {
      option = "texlab";
      display = "TeXLab";
      inherit config;
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.texlab = {
      enable = true;
      cmd = [(getExe pkgs.texlab) "run"];
      root_markers = [".git" ".latexmkrc" "latexmkrc" ".texlabroot" "texlabroot" ".texstudio" "Tectonic.toml"];
    };
  };
}
