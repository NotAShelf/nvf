{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) str nullOr;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline;
in {
  options.vim.assistant = {
    avante-nvim = {
      enable = mkEnableOption "complementary neovim plugin for avante.nvim";

      setupOpts = mkPluginSetupOption "avante-nvim" {
        provider = mkOption {
          type = nullOr str;
          default = null;
          description = "Provider used for Chat.";
        };

        vendors = mkOption {
          type = nullOr luaInline;
          default = null;
          description = "A provider is what connects Neovim to an LLM.";
        };
      };
    };
  };
}
