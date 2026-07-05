{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;

  cfg = config.vim.lsp.presets.vala-language-server;
in {
  options.vim.lsp.presets.vala-language-server = {
    enable = mkLspPresetEnableOption {
      option = "vala-language-server";
      display = "Vala";
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.vala-language-server = {
      enable = true;
      # We are wrapping the LSP with uncrustify in the path,
      # because it is an optional dependency to support formatting
      # <https://github.com/vala-lang/vala-language-server#dependencies>
      cmd = [
        "${pkgs.symlinkJoin {
          name = "vala-language-server-wrapper";
          paths = [pkgs.vala-language-server];
          meta.mainProgram = "vala-language-server";
          buildInputs = [pkgs.makeBinaryWrapper];
          postBuild = "wrapProgram $out/bin/vala-language-server --prefix PATH : ${pkgs.uncrustify}/bin";
        }}/bin/vala-language-server"
      ];
      root_markers = [".git"];
    };
  };
}
