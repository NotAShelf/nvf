{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) nvim mkIf mkMerge concatMapStringsSep;
  inherit (nvim.vim) mkVimBool;

  cfg = config.vim.utility.preview.markdownPreview;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = [pkgs.vimPlugins.markdown-preview-nvim];

    vim.configRC.markdown-preview = nvim.dag.entryAnywhere ''
      let g:mkdp_auto_start = ${mkVimBool cfg.autoStart}
      let g:mkdp_auto_close = ${mkVimBool cfg.autoClose}
      let g:mkdp_refresh_slow = ${mkVimBool cfg.lazyRefresh}
      let g:mkdp_filetypes = [${concatMapStringsSep ", " (x: "'" + x + "'") cfg.filetypes}]
      let g:mkdp_command_for_global = ${mkVimBool cfg.alwaysAllowPreview}
      let g:mkdp_open_to_the_world = ${mkVimBool cfg.broadcastServer}
      let g:mkdp_open_ip = '${cfg.customIP}'
      let g:mkdp_port = '${cfg.customPort}'
    '';
  };
}
