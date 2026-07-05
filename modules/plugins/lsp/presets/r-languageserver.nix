{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.lsp.presets.r-languageserver;
in {
  options.vim.lsp.presets.r-languageserver = {
    enable = mkLspPresetEnableOption {
      option = "r-languageserver";
      display = "R";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.r-languageserver = {
      enable = true;
      cmd = [
        "${pkgs.rWrapper.override {
          packages = [pkgs.rPackages.languageserver];
        }}/bin/R"
        "--no-echo"
        "-e"
        "languageserver::run()"
      ];
      root_markers = [".git"];
      root_dir = mkLuaInline ''
        function(bufnr, on_dir)
          on_dir(vim.fs.root(bufnr, '.git') or vim.uv.os_homedir())
        end
      '';
    };
  };
}
