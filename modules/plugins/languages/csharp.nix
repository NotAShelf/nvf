{
  lib,
  pkgs,
  config,
  options,
  ...
}: let
  inherit (builtins) attrNames concatMap;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) enum;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.strings) optionalString;
  inherit (lib.nvim.types) mkGrammarOption deprecatedSingleOrListOf;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.attrsets) mapListToAttrs;

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
      cmd = mkLuaInline ''
        {
          ${toLuaObject (getExe pkgs.omnisharp-roslyn)},
          '-z', -- https://github.com/OmniSharp/omnisharp-vscode/pull/4300
          '--hostPID',
          tostring(vim.fn.getpid()),
          'DotNet:enablePackageRestore=false',
          '--encoding',
          'utf-8',
          '--languageserver',
        }
      '';
      filetypes = ["cs" "vb"];
      root_dir = mkLuaInline ''
        function(bufnr, on_dir)
          local function find_root_pattern(fname, lua_pattern)
            return vim.fs.root(0, function(name, path)
              return name:match(lua_pattern)
            end)
          end

          local fname = vim.api.nvim_buf_get_name(bufnr)
          on_dir(find_root_pattern(fname, "%.sln$") or find_root_pattern(fname, "%.csproj$"))
        end
      '';
      init_options = {};
      capabilities = {
        workspace = {
          workspaceFolders = false; # https://github.com/OmniSharp/omnisharp-roslyn/issues/909
        };
      };
      on_attach = mkLuaInline ''
        function(client, bufnr)
          local oe = require("omnisharp_extended")
          ${mkLspBinding "goToDefinition" "oe.lsp_definition"}
          ${mkLspBinding "goToType" "oe.lsp_type_definition"}
          ${mkLspBinding "listReferences" "oe.lsp_references"}
          ${mkLspBinding "listImplementations" "oe.lsp_implementation"}
        end
      '';
      settings = {
        FormattingOptions = {
          # Enables support for reading code style, naming convention and analyzer
          # settings from .editorconfig.
          EnableEditorConfigSupport = true;
          # Specifies whether 'using' directives should be grouped and sorted during
          # document formatting.
          OrganizeImports = null;
        };
        MsBuild = {
          # If true, MSBuild project system will only load projects for files that
          # were opened in the editor. This setting is useful for big C# codebases
          # and allows for faster initialization of code navigation features only
          # for projects that are relevant to code that is being edited. With this
          # setting enabled OmniSharp may load fewer projects and may thus display
          # incomplete reference lists for symbols.
          LoadProjectsOnDemand = null;
        };
        RoslynExtensionsOptions = {
          # Enables support for roslyn analyzers, code fixes and rulesets.
          EnableAnalyzersSupport = null;
          # Enables support for showing unimported types and unimported extension
          # methods in completion lists. When committed, the appropriate using
          # directive will be added at the top of the current file. This option can
          # have a negative impact on initial completion responsiveness;
          # particularly for the first few completion sessions after opening a
          # solution.
          EnableImportCompletion = null;
          # Only run analyzers against open files when 'enableRoslynAnalyzers' is
          # true
          AnalyzeOpenDocumentsOnly = null;
          # Enables the possibility to see the code in external nuget dependencies
          EnableDecompilationSupport = null;
        };
        RenameOptions = {
          RenameInComments = null;
          RenameOverloads = null;
          RenameInStrings = null;
        };
        Sdk = {
          # Specifies whether to include preview versions of the .NET SDK when
          # determining which version to use for project loading.
          IncludePrereleases = true;
        };
      };
    };

    csharp_ls = {
      cmd = [(lib.getExe pkgs.csharp-ls)];
      filetypes = ["cs"];
      root_dir = mkLuaInline ''
        function(bufnr, on_dir)
          local function find_root_pattern(fname, lua_pattern)
            return vim.fs.root(0, function(name, path)
              return name:match(lua_pattern)
            end)
          end

          local fname = vim.api.nvim_buf_get_name(bufnr)
          on_dir(find_root_pattern(fname, "%.sln$") or find_root_pattern(fname, "%.csproj$"))
        end
      '';
      init_options = {
        AutomaticWorkspaceInit = true;
      };
    };

    roslyn_ls = {
      cmd = mkLuaInline ''
        {
          ${toLuaObject (getExe pkgs.roslyn-ls)},
          '--logLevel=Warning',
          '--extensionLogDirectory=' .. vim.fs.dirname(vim.lsp.get_log_path()),
          '--stdio',
        }
      '';

      filetypes = ["cs"];
      root_dir = mkLuaInline ''
        function(bufnr, on_dir)
          local function find_root_pattern(fname, lua_pattern)
            return vim.fs.root(0, function(name, path)
              return name:match(lua_pattern)
            end)
          end

          local fname = vim.api.nvim_buf_get_name(bufnr)
          on_dir(find_root_pattern(fname, "%.sln$") or find_root_pattern(fname, "%.csproj$"))
        end
      '';
      init_options = {};
    };
  };

  extraServerPlugins = {
    omnisharp = ["omnisharp-extended-lsp-nvim"];
    csharp_ls = ["csharpls-extended-lsp-nvim"];
    roslyn_ls = [];
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
        servers = mkOption {
          description = "C# LSP server to use";
          type = deprecatedSingleOrListOf "vim.language.csharp.lsp.servers" (enum (attrNames servers));
          default = defaultServers;
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
      vim.startPlugins = concatMap (server: extraServerPlugins.${server}) cfg.lsp.servers;
      vim.lsp.servers =
        mapListToAttrs (name: {
          inherit name;
          value = servers.${name};
        })
        cfg.lsp.servers;
    })
  ]);
}
