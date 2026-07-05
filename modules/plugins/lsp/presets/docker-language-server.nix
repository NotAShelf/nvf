{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.docker-language-server;
in {
  options.vim.lsp.presets.docker-language-server = {
    enable = mkLspPresetEnableOption {
      option = "docker-language-server";
      display = "Docker";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.docker-language-server = {
      enable = true;
      cmd = ["${pkgs.docker-language-server}/bin/docker-language-server" "start" "--stdio"];
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
