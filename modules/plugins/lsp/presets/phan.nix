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

  cfg = config.vim.lsp.presets.phan;
in {
  options.vim.lsp.presets.phan = {
    enable = mkLspPresetEnableOption "phan" "Phan" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.phan = {
      enable = true;
      cmd = [
        (getExe pkgs.php85Packages.phan)
        "-m"
        "json"
        "--no-color"
        "--no-progress-bar"
        "-x"
        "-u"
        "-S"
        "--language-server-on-stdin"
        "--allow-polyfill-parser"
      ];
      root_dir = mkLuaInline ''
        function(bufnr, on_dir)
          local fname = vim.api.nvim_buf_get_name(bufnr)
          local cwd = assert(vim.uv.cwd())
          local root = vim.fs.root(fname, { 'composer.json', '.git' })

          -- prefer cwd if root is a descendant
          on_dir(root and vim.fs.relpath(cwd, root) and cwd)
        end
      '';
    };
  };
}
