{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.texlab;
in {
  options.vim.lsp.presets.texlab = {
    enable = mkLspPresetEnableOption {
      option = "texlab";
      display = "TeXLab";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.texlab = {
      enable = true;
      cmd = ["${pkgs.texlab}/bin/texlab" "run"];
      root_markers = [".git" ".latexmkrc" "latexmkrc" ".texlabroot" "texlabroot" ".texstudio" "Tectonic.toml"];
    };
  };
}
