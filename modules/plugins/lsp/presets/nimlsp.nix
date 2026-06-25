{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.lsp.presets.nimlsp;
in {
  options.vim.lsp.presets.nimlsp = {
    enable = mkLspPresetEnableOption "nimlsp" "Nim" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.nimlsp = {
      enable = true;
      cmd = [(getExe pkgs.nimlsp)];
      root_dir = mkLuaInline ''
        function(bufnr, on_dir)
          local fname = vim.api.nvim_buf_get_name(bufnr)
          on_dir(
            util.root_pattern '*.nimble'(fname) or vim.fs.dirname(vim.fs.find('.git', { path = fname, upward = true })[1])
          )
        end
      '';
    };
  };
}
