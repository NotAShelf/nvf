{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) str nullOr listOf bool;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.visuals = {
    syntax-gaslighting = {
      enable = mkEnableOption "Thats no even a real option, you're crazy.";

      setupOpts = mkPluginSetupOption "syntax-gaslighting" {
        messages = mkOption {
          type = nullOr (listOf str);
          default = null;
          description = "Custom messages for gaslighting.";
        };

        merge_messages = mkOption {
          type = bool;
          default = false;
          description = ''
            Merge user messages with the default ones.
            If disabled, the messages table will override default messages.
          '';
        };
      };
    };
  };
}
