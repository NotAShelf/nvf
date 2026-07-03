{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkFormatterPresetEnableOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.formatter.conform-nvim.presets.ocamlformat;
in {
  options.vim.formatter.conform-nvim.presets.ocamlformat = {
    enable = mkFormatterPresetEnableOption {
      option = "ocamlformat";
      display = "OCaml";
    };
  };

  config = mkIf cfg.enable {
    vim.formatter.conform-nvim.setupOpts.formatters.ocamlformat = {
      command = "${pkgs.ocamlformat}/bin/ocamlformat";
      args = mkLuaInline ''
        function(self, ctx)
          return {
            "--module-indent",      ctx.shiftwidth,
            "--type-decl-indent",   ctx.shiftwidth,
            "--let-binding-indent", ctx.shiftwidth,
            "--extension-indent",   ctx.shiftwidth,
            "--function-indent",    ctx.shiftwidth,
            "--enable-outside-detected-project",
            "--name", "$FILENAME",
            "-"
          }
        end
      '';
    };
  };
}
