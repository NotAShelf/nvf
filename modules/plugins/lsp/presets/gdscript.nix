{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.lsp.presets.gdscript;
in {
  options.vim.lsp.presets.gdscript = {
    enable = mkLspPresetEnableOption {
      option = "gdscript";
      display = "GDScript";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.gdscript = {
      enable = true;
      cmd = mkLuaInline ''
        vim.lsp.rpc.connect('127.0.0.1', 6005)
      '';
      root_markers = ["project.godot"];
    };
  };
}
