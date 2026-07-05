{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.lsp.presets.arduino-language-server;
in {
  options.vim.lsp.presets.arduino-language-server = {
    enable = mkLspPresetEnableOption {
      option = "arduino-language-server";
      display = "Arduino";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.arduino-language-server = {
      enable = true;
      cmd = [
        "${pkgs.arduino-language-server}/bin/arduino-language-server"
        "-clangd"
        "${pkgs.clang-tools}/bin/clangd"
        "-cli"
        "${pkgs.arduino-cli}/bin/arduino-cli"
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
