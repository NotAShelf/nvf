{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.lsp.presets.bash-language-server;
in {
  options.vim.lsp.presets.bash-language-server = {
    enable = mkLspPresetEnableOption "bash-language-server" "Bash" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.bash-language-server = {
      enable = true;
      cmd = [(getExe pkgs.bash-language-server) "start"];
      root_markers = [".git"];
      settings = {
        bashIde = {
          globPattern = mkLuaInline "vim.env.GLOB_PATTERN or '*@(.sh|.inc|.bash|.command)'";
        };
      };
    };
  };
}
