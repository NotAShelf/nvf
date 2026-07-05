{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.solargraph;
in {
  options.vim.lsp.presets.solargraph = {
    enable = mkLspPresetEnableOption {
      option = "solargraph";
      display = "Solargraph";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.solargraph = {
      enable = true;
      cmd = ["${pkgs.rubyPackages.solargraph}/bin/solargraph" "stdio"];
      root_markers = [".git"];
      settings = {
        solargraph = {
          diagnostics = true;
        };
      };
      flags = {
        debounce_text_changes = 150;
      };
      init_options = {
        formatting = true;
      };
    };
  };
}
