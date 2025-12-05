{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (lib.types) enum;
  inherit (lib.nvim.types) mkGrammarOption deprecatedSingleOrListOf;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.ocaml;

  defaultServers = ["ocaml-lsp"];
  servers = {
    ocaml-lsp = {
      enable = true;
      cmd = [(getExe pkgs.ocamlPackages.ocaml-lsp)];
      filetypes = ["ocaml" "menhir" "ocamlinterface" "ocamllex" "reason" "dune"];
      root_dir =
        mkLuaInline
        /*
        lua
        */
        ''
          function(bufnr, on_dir)
            local fname = vim.api.nvim_buf_get_name(bufnr)
            on_dir(util.root_pattern('*.opam', 'esy.json', 'package.json', '.git', 'dune-project', 'dune-workspace')(fname))
          end
        '';
      get_language_id =
        mkLuaInline
        /*
        lua
        */
        ''
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

  defaultFormat = ["ocamlformat"];
  formats = {
    ocamlformat = {
      command = getExe pkgs.ocamlPackages.ocamlformat;
    };
  };
in {
  options.vim.languages.ocaml = {
    enable = mkEnableOption "OCaml language support";

    treesitter = {
      enable = mkEnableOption "OCaml treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "ocaml";
    };

    lsp = {
      enable = mkEnableOption "OCaml LSP support" // {default = config.vim.lsp.enable;};

      servers = mkOption {
        type = deprecatedSingleOrListOf "vim.language.ocaml.lsp.servers" (enum (attrNames servers));
        default = defaultServers;
        description = "OCaml LSP server to use";
      };
    };

    format = {
      enable = mkEnableOption "OCaml formatting support (ocamlformat)" // {default = config.vim.languages.enableFormat;};
      type = mkOption {
        type = deprecatedSingleOrListOf "vim.language.ocaml.format.type" (enum (attrNames formats));
        default = defaultFormat;
        description = "OCaml formatter to use";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.lsp.enable {
      vim.lsp.servers =
        mapListToAttrs (n: {
          name = n;
          value = servers.${n};
        })
        cfg.lsp.servers;
    })

    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft.ocaml = cfg.format.type;
          formatters =
            mapListToAttrs (name: {
              inherit name;
              value = formats.${name};
            })
            cfg.format.type;
        };
      };
    })
  ]);
}
