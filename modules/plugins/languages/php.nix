{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) enum;
  inherit (lib.nvim.types) mkGrammarOption singleOrListOf;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.languages.php;

  defaultServers = ["phpactor"];
  servers = {
    phpactor = {
      enable = true;
      cmd = [(getExe pkgs.phpactor) "language-server"];
      filetypes = ["php"];
      root_markers = [".git" "composer.json" ".phpactor.json" ".phpactor.yml"];
      workspace_required = true;
    };

    phan = {
      enable = true;
      cmd = [
        (getExe pkgs.php81Packages.phan)
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
      filetypes = ["php"];
      root_dir =
        mkLuaInline
        /*
        lua
        */
        ''
          function(bufnr, on_dir)
            local fname = vim.api.nvim_buf_get_name(bufnr)
            local cwd = assert(vim.uv.cwd())
            local root = vim.fs.root(fname, { 'composer.json', '.git' })

            -- prefer cwd if root is a descendant
            on_dir(root and vim.fs.relpath(cwd, root) and cwd)
          end
        '';
    };

    intelephense = {
      enable = true;
      cmd = [(getExe pkgs.intelephense) "--stdio"];
      filetypes = ["php"];
      root_markers = ["composer.json" ".git"];
    };
  };
in {
  options.vim.languages.php = {
    enable = mkEnableOption "PHP language support";

    treesitter = {
      enable = mkEnableOption "PHP treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "php";
    };

    lsp = {
      enable = mkEnableOption "PHP LSP support" // {default = config.vim.lsp.enable;};

      servers = mkOption {
        type = singleOrListOf (enum (attrNames servers));
        default = defaultServers;
        description = "PHP LSP server to use";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.servers =
        mapListToAttrs (n: {
          name = n;
          value = servers.${n};
        })
        cfg.lsp.servers;
    })
  ]);
}
