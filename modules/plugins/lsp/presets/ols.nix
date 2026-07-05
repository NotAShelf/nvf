{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.lsp.presets.ols;
in {
  options.vim.lsp.presets.ols = {
    enable = mkLspPresetEnableOption {
      option = "ols";
      display = "Odin";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.ols = {
      enable = true;
      cmd = ["${pkgs.ols}/bin/ols"];
      root_dir = mkLuaInline ''
        function(bufnr, on_dir)
          local fname = vim.api.nvim_buf_get_name(bufnr)
          on_dir(util.root_pattern('ols.json', '.git', '*.odin')(fname))
        end'';
    };
  };
}
