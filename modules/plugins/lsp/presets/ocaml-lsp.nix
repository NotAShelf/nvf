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

  cfg = config.vim.lsp.presets.ocaml-lsp;
in {
  options.vim.lsp.presets.ocaml-lsp = {
    enable = mkLspPresetEnableOption "ocaml-lsp" "OCaml" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.ocaml-lsp = {
      enable = true;
      cmd = [(getExe pkgs.ocamlPackages.ocaml-lsp)];
      root_dir = mkLuaInline ''
        function(bufnr, on_dir)
          local fname = vim.api.nvim_buf_get_name(bufnr)
          on_dir(util.root_pattern('*.opam', 'esy.json', 'package.json', '.git', 'dune-project', 'dune-workspace')(fname))
        end
      '';
      get_language_id = mkLuaInline ''
        function(_, ftype)
          local language_id_of = {
            menhir = 'ocaml.menhir',
            ocaml = 'ocaml',
            ocamlinterface = 'ocaml.interface',
            ocamllex = 'ocaml.ocamllex',
            reason = 'reason',
            dune = 'dune',
          }

          return language_id_of[ftype]
        end
      '';
    };
  };
}
