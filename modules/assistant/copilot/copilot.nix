{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.assistant.copilot = {
    enable = mkEnableOption "Enable GitHub Copilot";

    copilot_node_command = mkOption {
      type = types.str;
      default = "${lib.getExe pkgs.nodejs-slim-16_x}";
      description = "Path to nodejs";
    };
  };
}
