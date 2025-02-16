{
  lib,
  pkgs,
  config,
  options,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) either listOf package str enum;
  inherit (lib.lists) isList;
  inherit (lib.strings) optionalString;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.lua) expToLua toLuaObject;

  lspKeyConfig = config.vim.lsp.mappings;
  lspKeyOptions = options.vim.lsp.mappings;
  mkLspBinding = optionName: action: let
    key = lspKeyConfig.${optionName};
    desc = lspKeyOptions.${optionName}.description;
  in
    optionalString (key != null) "vim.keymap.set('n', '${key}', ${action}, {buffer=bufnr, noremap=true, silent=true, desc='${desc}'})";

  packageToCmd = package: defaultCmd:
    if isList package
    then expToLua package
    else ''{ "${package}/bin/${defaultCmd}" }'';

  # Omnisharp doesn't have colors in popup docs for some reason, and I've also
  # seen mentions of it being way slower, so until someone finds missing
  # functionality, this will be the default.
  defaultServer = "csharp_ls";
  servers = {
    omnisharp = {
      package = pkgs.omnisharp-roslyn;
      internalFormatter = true;
      options = {
        capabilities = mkLuaInline "capabilities";
        on_attach = mkLuaInline ''
          function(client, bufnr)
            default_on_attach(client, bufnr)

            local oe = require("omnisharp_extended")
            ${mkLspBinding "goToDefinition" "oe.lsp_definition"}
            ${mkLspBinding "goToType" "oe.lsp_type_definition"}
            ${mkLspBinding "listReferences" "oe.lsp_references"}
            ${mkLspBinding "listImplementations" "oe.lsp_implementation"}
          end,
        '';
        filetypes = ["cs" "vb"];
        cmd =
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ["${packageToCmd cfg.lsp.package "OmniSharp"}"];
        single_file_support = false; # upstream default
        init_options = {};
        handlers = {
          "textDocument/definition" = mkLuaInline "extended_handler";
          "textDocument/typeDefinition" = mkLuaInline "extended_handler";
        };
      };
    };

    csharp_ls = {
      package = pkgs.csharp-ls;
      internalFormatter = true;
      options = {
        capabilities = mkLuaInline "capabilities";
        on_attach = mkLuaInline "default_on_attach";
        filetypes = ["cs"];
        offset_encoding = "utf-32";
        cmd =
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ["${packageToCmd cfg.lsp.package "csharp-ls"}"];
        single_file_support = false; # upstream default
        init_options = {AutomaticWorkspaceInit = true;};
        handlers = {
          "textDocument/definition" = mkLuaInline "extended_handler";
          "textDocument/typeDefinition" = mkLuaInline "extended_handler";
        };
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
        enable = mkEnableOption "C# LSP support" // {default = config.vim.languages.enableLSP;};
        server = mkOption {
          description = "C# LSP server to use";
          type = enum (attrNames servers);
          default = defaultServer;
        };

        package = mkOption {
          description = "C# LSP server package, or the command to run as a list of strings";
          type = either package (listOf str);
          default = servers.${cfg.lsp.server}.package;
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.startPlugins = extraServerPlugins.${cfg.lsp.server} or [];
      vim.lsp.lspconfig.enable = true;
      vim.lsp.lspconfig.sources.csharp-lsp = ''
        lspconfig.${toLuaObject cfg.lsp.server}.setup(${toLuaObject cfg.lsp.options})
      '';
    })
  ]);
}
