{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) either listOf package str enum;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  defaultServer = ["fsautocomplete"];
  servers = {
    fsautocomplete.options = {
      cmd = [(getExe pkgs.fsautocomplete) "--adaptive-lsp-server-enabled"];
      filetypes = ["fsharp"];
      root_dir = mkLuaInline ''
        function(bufnr, cb)
          local root = vim.fs.root(bufnr, function(name, path)
            return name == ".git" or name:match("%.sln$") or name:match("%.fsproj$")
          end)
          if root then cb(root) end
        end
      '';
      init_options = {
        AutomaticWorkspaceInit = true;
      };
      settings = {
        FSharp = {
          keywordsAutocomplete = true;
          ExternalAutocomplete = false;
          Linter = true;
          UnionCaseStubGeneration = true;
          UnionCaseStubGenerationBody = ''failwith "Not Implemented"'';
          RecordStubGeneration = true;
          RecordStubGenerationBody = ''failwith "Not Implemented"'';
          InterfaceStubGeneration = true;
          InterfaceStubGenerationObjectIdentifier = "this";
          InterfaceStubGenerationMethodBody = ''failwith "Not Implemented"'';
          UnusedOpensAnalyzer = true;
          UnusedDeclarationsAnalyzer = true;
          UseSdkScripts = true;
          SimplifyNameAnalyzer = true;
          ResolveNamespaces = true;
          EnableReferenceCodeLens = true;
        };
      };
    };
  };

  defaultFormat = "fantomas";
  formats = {
    fantomas = {
      package = pkgs.fantomas;
    };
  };

  cfg = config.vim.languages.fsharp;
in {
  options = {
    vim.languages.fsharp = {
      enable = mkEnableOption "F# language support";

      treesitter = {
        enable = mkEnableOption "F# treesitter" // {default = config.vim.languages.enableTreesitter;};
        package = mkGrammarOption pkgs "fsharp";
      };

      lsp = {
        enable = mkEnableOption "F# LSP support" // {default = config.vim.languages.enableLSP;};
        server = mkOption {
          type = listOf (enum (attrNames servers));
          default = defaultServer;
          description = "F# LSP server to use";
        };

        package = mkOption {
          type = either package (listOf str);
          default = servers.${cfg.lsp.server}.package;
          example = ''[lib.getExe pkgs.fsautocomplete "--state-directory" "~/.cache/fsautocomplete"]'';
          description = "F# LSP server package, or the command to run as a list of strings";
        };
      };
      format = {
        enable = mkEnableOption "F# formatting" // {default = config.vim.languages.enableFormat;};

        type = mkOption {
          type = enum (attrNames formats);
          default = defaultFormat;
          description = "F# formatter to use";
        };

        package = mkOption {
          type = package;
          default = formats.${cfg.format.type}.package;
          description = "F# formatter package";
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
      vim.lsp.servers =
        mapListToAttrs (name: {
          inherit name;
          value = servers.${name}.options;
        })
        cfg.lsp.server;
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts.formatters_by_ft.fsharp = [cfg.format.type];
        setupOpts.formatters.${cfg.format.type} = {
          command = getExe cfg.format.package;
        };
      };
    })
  ]);
}
