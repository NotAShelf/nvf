{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.lsp.presets.vtsls;
in {
  options.vim.lsp.presets.vtsls = {
    enable = mkLspPresetEnableOption {
      option = "vtsls";
      display = "Vue.js Typescript";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.vtsls = {
      enable = true;
      cmd = [(getExe pkgs.vtsls) "--stdio"];
      root_markers = [".git" "tsconfig.json" "package.json"];
      settings = {
        vtsls = {
          tsserver.globalPlugins = [
            {
              name = "@vue/typescript-plugin";
              location = "${pkgs.vue-language-server}/lib/language-tools/packages/language-server";
              languages = ["vue"];
              configNamespace = "typescript";
            }
          ];
        };
      };
      capabilities.semanticTokensProvider = false;
    };
  };
}
