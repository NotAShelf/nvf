{
  inputs,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.some-sass-language-server;
in {
  options.vim.lsp.presets.some-sass-language-server = {
    enable = mkLspPresetEnableOption "some-sass-language-server" "Some Sass" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.some-sass-language-server = {
      enable = true;
      cmd = [(getExe inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.some-sass-language-server) "--stdio"];
      root_markers = [".git" "package.json"];
      # <https://wkillerud.github.io/some-sass/language-server/settings.html>
      settings = {
        somesass = {
          scss.completion.suggestFromUseOnly = true;
          sass.completion.suggestFromUseOnly = true;
        };
      };
    };
  };
}
