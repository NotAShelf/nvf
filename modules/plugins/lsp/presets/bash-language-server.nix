{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.lsp.presets.bash-language-server;
in {
  options.vim.lsp.presets.bash-language-server = {
    enable = mkLspPresetEnableOption {
      option = "bash-language-server";
      display = "Bash";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.bash-language-server = {
      enable = true;
      cmd = ["${pkgs.bash-language-server}/bin/bash-language-server" "start"];
      root_markers = [".git"];
      settings = {
        bashIde = {
          globPattern = mkLuaInline "vim.env.GLOB_PATTERN or '*@(.sh|.inc|.bash|.command)'";
        };
      };
    };
  };
}
