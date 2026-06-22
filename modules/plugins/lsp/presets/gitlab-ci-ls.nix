{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.gitlab-ci-ls;
in {
  options.vim.lsp.presets.gitlab-ci-ls = {
    enable = mkLspPresetEnableOption "gitlab-ci-ls" "GitLab CI" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.gitlab-ci-ls = {
      enable = true;
      cmd = [(getExe pkgs.gitlab-ci-ls)];
      root_markers = [".git" ".gitlab"];
    };
  };
}
