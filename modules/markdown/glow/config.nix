{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.vim.markdown.glow;
in {
  config = (mkIf cfg.enable) {
    vim.startPlugins = ["glow-nvim"];
    vim.globals = {
      "glow_binary_path" = "${pkgs.glow}/bin";
    };

    vim.configRC.glow = nvim.dag.entryAnywhere ''
      autocmd FileType markdown noremap <leader>p :Glow<CR>
    '';
  };
}
