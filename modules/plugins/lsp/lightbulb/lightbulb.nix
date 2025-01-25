{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) listOf str either;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline;
in {
  options.vim.lsp = {
    lightbulb = {
      enable = mkEnableOption "Lightbulb for code actions. Requires an emoji font";
      setupOpts = mkPluginSetupOption "nvim-lightbulb" {};
      autocmd = {
        enable = mkEnableOption "updating lightbulb glyph automatically" // {default = true;};
        events = mkOption {
          type = listOf str;
          default = ["CursorHold" "CursorHoldI"];
          description = "Events on which to update nvim-lightbulb glyphs";
        };

        pattern = mkOption {
          type = either str luaInline;
          default = "*";
          description = ''
            File patterns or buffer names to match, determining which files or buffers trigger
            glyph updates.
          '';
        };
      };
    };
  };
}
