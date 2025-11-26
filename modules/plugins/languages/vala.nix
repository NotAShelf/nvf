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
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.languages.vala;

  defaultServers = ["vala_ls"];
  servers = {
    vala_ls = {
      enable = true;
      cmd = [
        (getExe (pkgs.symlinkJoin {
          name = "vala-language-server-wrapper";
          paths = [pkgs.vala-language-server];
          meta.mainProgram = "vala-language-server-wrapper";
          buildInputs = [pkgs.makeBinaryWrapper];
          postBuild = ''
            wrapProgram $out/bin/vala-language-server \
              --prefix PATH : ${pkgs.uncrustify}/bin
          '';
        }))
      ];
      filetypes = ["vala" "genie"];
      root_dir = mkLuaInline ''
        function(bufnr, on_dir)
          local meson_matcher = function(path)
            local pattern = 'meson.build'
            local f = vim.fn.glob(table.concat({ path, pattern }, '/'))
            if f == ''' then
              return nil
            end
            for line in io.lines(f) do
              -- skip meson comments
              if not line:match '^%s*#.*' then
                local str = line:gsub('%s+', ''')
                if str ~= ''' then
                  if str:match '^project%(' then
                    return path
                  else
                    break
                  end
                end
              end
            end
          end

          local fname = vim.api.nvim_buf_get_name(bufnr)
          local root = vim.iter(vim.fs.parents(fname)):find(meson_matcher)
          on_dir(root or vim.fs.dirname(vim.fs.find('.git', { path = fname, upward = true })[1]))
        end
      '';
    };
  };
in {
  options.vim.languages.vala = {
    enable = mkEnableOption "Vala language support";

    treesitter = {
      enable = mkEnableOption "Vala treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "vala";
    };

    lsp = {
      enable = mkEnableOption "Vala LSP support" // {default = config.vim.lsp.enable;};
      servers = mkOption {
        type = deprecatedSingleOrListOf "vim.language.vala.lsp.servers" (enum (attrNames servers));
        default = defaultServers;
        description = "Vala LSP server to use";
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
