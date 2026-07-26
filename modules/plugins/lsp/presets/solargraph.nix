{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.meta) getExe;

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
      cmd = [(getExe pkgs.rubyPackages.solargraph) "stdio"];
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
