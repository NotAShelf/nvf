{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.formatter.conform-nvim.presets.emacs;
in {
  options.vim.formatter.conform-nvim.presets.emacs = {
    enable = mkFormatterPresetEnableOption {
      option = "emacs";
      display = "Emacs";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.emacs = {
      command = getExe pkgs.emacs-nox;
      args = [
        "--batch"
        "--eval"
        # elisp
        ''
          (let ((file (car command-line-args-left)))
            (with-current-buffer (find-file-noselect file)
              (lisp-mode)
              (indent-region (point-min) (point-max))
              (save-buffer)))
        ''
        "$FILENAME"
      ];
      stdin = false;
    };
  };
}
