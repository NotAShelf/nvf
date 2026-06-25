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

  cfg = config.vim.lsp.presets.nushell;
in {
  options.vim.lsp.presets.nushell = {
    enable = mkLspPresetEnableOption "nushell" "NuShell" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.nushell = {
      enable = true;
      cmd = [(getExe pkgs.nushell) "--no-config-file" "--lsp"];
      root_dir = mkLuaInline ''
        function(bufnr, on_dir)
          on_dir(vim.fs.root(bufnr, { '.git' }) or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)))
        end
      '';
    };
  };
}
