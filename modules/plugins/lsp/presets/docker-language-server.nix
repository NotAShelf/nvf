{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.docker-language-server;
in {
  options.vim.lsp.presets.docker-language-server = {
    enable = mkLspPresetEnableOption "docker-language-server" "Docker" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.docker-language-server = {
      enable = true;
      cmd = [(getExe pkgs.docker-language-server) "start" "--stdio"];
      root_markers = [
        ".git"
        "Dockerfile"
        "docker-compose.yaml"
        "docker-compose.yml"
        "compose.yaml"
        "compose.yml"
        "docker-bake.json"
        "docker-bake.hcl"
      ];
    };
  };
}
