{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.formatter.conform-nvim.presets.sbcl;
in {
  options.vim.formatter.conform-nvim.presets.sbcl = {
    enable = mkFormatterPresetEnableOption {
      option = "sbcl";
      display = "Steel Bank Common Lisp Compiler";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.sbcl = {
      command = getExe pkgs.sbcl;
      args = [
        "--noinform"
        "--disable-debugger"
        "--no-sysinit"
        "--no-userinit"
        "--non-interactive"
        "--eval"
        # lisp
        ''
          (let ((*print-case* :downcase))
            (loop for form = (read *standard-input* nil :eof)
                  until (eq form :eof)
                  do (write form :pretty t) (terpri)))
        ''
      ];
    };
  };
}
