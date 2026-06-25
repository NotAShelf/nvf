{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe getExe';
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.lsp.presets.arduino-language-server;
in {
  options.vim.lsp.presets.arduino-language-server = {
    enable = mkLspPresetEnableOption "arduino-language-server" "Arduino" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.arduino-language-server = {
      enable = true;
      cmd = [
        (getExe pkgs.arduino-language-server)
        "-clangd"
        (getExe' pkgs.clang-tools "clangd")
        "-cli"
        (getExe pkgs.arduino-cli)
        "-cli-config"
        "$HOME/.arduino15/arduino-cli.yaml"
      ];
      root_dir = mkLuaInline ''
        function(bufnr, on_dir)
          local fname = vim.api.nvim_buf_get_name(bufnr)
          on_dir(util.root_pattern("*.ino")(fname))
        end
      '';
      capabilities = {
        textDocument = {
          semanticTokens = mkLuaInline "vim.NIL";
        };
        workspace = {
          semanticTokens = mkLuaInline "vim.NIL";
        };
      };
    };
  };
}
