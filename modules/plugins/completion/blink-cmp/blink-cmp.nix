{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption literalMD;
  inherit (lib.types) listOf str either oneOf attrsOf;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline;
in {
  options.vim.autocomplete.blink-cmp = {
    enable = mkEnableOption "blink.cmp";
    setupOpts = mkPluginSetupOption "blink.cmp" {
      sources = {
        default = mkOption {
          type = listOf str;
          description = "Default list of sources to enable for completion.";
          default = ["lsp" "path" "snippets" "buffer"];
        };
      };

      keymap = mkOption {
        type = attrsOf (oneOf [luaInline str (listOf (either str luaInline))]);
        default = {};
        description = "blink.cmp keymap";
        example = literalMD ''
          ```nix
          "<Up>" = ["select_prev" "fallback"];
          "<C-n>" = [
            (lib.generators.mkLuaInline ''''
              function(cmp)
                if some_condition then return end -- runs the next command
                  return true -- doesn't run the next command
                end,
            '''')
            "select_next"
          ];
          ```
        '';
      };
    };
  };
}
