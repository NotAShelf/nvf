{
  lib,
  pkgs,
  config,
  options,
  ...
}: let
  inherit (lib.generators) mkLuaInline;
  inherit (lib.lists) flatten map;
  inherit (lib.options) mkEnableOption;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.strings) optionalString;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.types) mkGrammarOption mkServersOption;

  lspKeyConfig = config.vim.lsp.mappings;
  lspKeyOptions = options.vim.lsp.mappings;
  mkLspBinding = optionName: action: let
    key = lspKeyConfig.${optionName};
    desc = lspKeyOptions.${optionName}.description;
  in
    optionalString (key != null) "vim.keymap.set('n', '${key}', ${action}, {buffer=bufnr, noremap=true, silent=true, desc='${desc}'})";

  # Omnisharp doesn't have colors in popup docs for some reason, and I've also
  # seen mentions of it being way slower, so until someone finds missing
  # functionality, this will be the default.
  defaultServers = ["csharp_ls"];
  servers = {
    omnisharp = {
      enable = true;
      cmd = [(getExe pkgs.omnisharp-roslyn)];
      filetypes = ["cs"];
      root_dir =
        mkLuaInline
        /*
        lua
        */
        ''
          function(bufnr, on_dir)
            local fname = vim.api.nvim_buf_get_name(bufnr)
            on_dir(util.root_pattern('*.sln', '*.csproj', '.git')(fname))
          end
        '';
      on_attach =
        mkLuaInline
        /*
        lua
        */
        ''
          function(client, bufnr)
            default_on_attach(client, bufnr)

            local oe = require("omnisharp_extended")
            ${mkLspBinding "goToDefinition" "oe.lsp_definition"}
            ${mkLspBinding "goToType" "oe.lsp_type_definition"}
            ${mkLspBinding "listReferences" "oe.lsp_references"}
            ${mkLspBinding "listImplementations" "oe.lsp_implementation"}
          end
        '';
    };

    csharp_ls = {
      enable = true;
      cmd = [(getExe pkgs.csharp-ls)];
      filetypes = ["cs"];
      root_dir =
        mkLuaInline
        /*
        lua
        */
        ''
          function(bufnr, on_dir)
            local fname = vim.api.nvim_buf_get_name(bufnr)
            on_dir(util.root_pattern('*.sln', '*.csproj', '.git')(fname))
          end
        '';

      handlers = {
        "textDocument/definition" =
          mkLuaInline
          /*
          lua
          */
          "require('csharpls_extended').handler";
        "textDocument/typeDefinition" =
          mkLuaInline
          /*
          lua
          */
          "require('csharpls_extended').handler";
      };
    };
  };

  extraServerPlugins = {
    omnisharp = ["omnisharp-extended-lsp-nvim"];
    csharp_ls = ["csharpls-extended-lsp-nvim"];
  };

  cfg = config.vim.languages.csharp;
in {
  options = {
    vim.languages.csharp = {
      enable = mkEnableOption "C# language support";

      treesitter = {
        enable = mkEnableOption "C# treesitter" // {default = config.vim.languages.enableTreesitter;};
        package = mkGrammarOption pkgs "c-sharp";
      };

      lsp = {
        enable = mkEnableOption "C# LSP support" // {default = config.vim.lsp.enable;};
        servers = mkServersOption "C#" servers defaultServers;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.startPlugins = flatten (map (s: extraServerPlugins.${s}) cfg.lsp.servers);
      vim.lsp.servers =
        mapListToAttrs (n: {
          name = n;
          value = servers.${n};
        })
        cfg.lsp.servers;
    })
  ]);
}
