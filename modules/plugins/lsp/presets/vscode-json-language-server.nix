{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.lsp.presets.vscode-json-language-server;
in {
  options.vim.lsp.presets.vscode-json-language-server = {
    enable = mkLspPresetEnableOption {
      option = "vscode-json-language-server";
      display = "VSCode JSON";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.vscode-json-language-server = {
      enable = true;
      cmd = ["${pkgs.vscode-langservers-extracted}/bin/vscode-json-language-server" "--stdio"];
      root_markers = [".git"];
      init_options = {provideFormatter = true;};
      get_language_id = mkLuaInline ''
        function(_, ft)
          --[[
            The LSP only supports `json` and `jsonc`.
            The fallback for any unknown file types is `json`.
            Mapping `json5` to `jsonc` generates more accurate results,
            because `jsonc` is a subset of `json5`.
          ]]--
          if ft == "json5" then
            return "jsonc"
          end
          return ft
        end
      '';
    };
  };
}
