{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.beancount-language-server;
in {
  options.vim.lsp.presets.beancount-language-server = {
    enable = mkLspPresetEnableOption {
      option = "beancount-language-server";
      display = "Beancount";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.beancount-language-server = {
      enable = true;
      root_markers = [".git"];
      cmd = [
        # Wrap the language server to ensure 'bean-check' and 'bean-format'
        # from 'pkgs.beancount' are in the PATH when the server runs.
        (getExe (
          pkgs.symlinkJoin {
            name = "beancount-language-server-wrapped";
            paths = [pkgs.beancount-language-server];
            meta.mainProgram = "beancount-language-server";
            buildInputs = [pkgs.makeBinaryWrapper];
            postBuild = ''
              wrapProgram $out/bin/beancount-language-server \
                --suffix PATH : ${pkgs.beancount}/bin
                # suffix add to path to allow users beancount in PATH to take precedence.
            '';
          }
        ))
      ];
    };
  };
}
