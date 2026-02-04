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

  # NOTE: roslyn is the most feature-rich option, and its Razor integration is better than csharp-ls (which only supports .cshtml).
  defaultServers = ["roslyn"];
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
      cmd = [(lib.getExe pkgs.csharp-ls) "--features" "razor-support"];
      filetypes = ["cs" "razor"];
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

    roslyn = let
      pkg = pkgs.vscode-extensions.ms-dotnettools.csharp;
      pluginRoot = "${pkg}/share/vscode/extensions/ms-dotnettools.csharp";
      exe = "${pluginRoot}/.roslyn/Microsoft.CodeAnalysis.LanguageServer";
      razorSourceGenerator = "${pluginRoot}/.razorExtension/Microsoft.CodeAnalysis.LanguageServer";
      razorDesignTimePath = "${pluginRoot}/.razorExtension/Targets/Microsoft.NET.Sdk.Razor.DesignTime.targets";
      razorExtension = "${pluginRoot}/.razorExtension/Microsoft.VisualStudioCode.RazorExtension.dll";
    in {
      cmd = mkLuaInline ''
        {
          "dotnet",
          "${exe}.dll",
          "--stdio",
          "--logLevel=Information",
          "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path()),
          "--razorSourceGenerator=${razorSourceGenerator}",
          "--razorDesignTimePath=${razorDesignTimePath}",
          "--extension=${razorExtension}",
        }
      '';

      filetypes = ["cs" "razor"];
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
    roslyn = ["roslyn-nvim"];
  };

  cfg = config.vim.languages.csharp;
in {
  options = {
    vim.languages.csharp = {
      enable = mkEnableOption ''
        C# language support.

        ::: {.note}
        This feature will not work if the .NET SDK is not installed.
        Both `roslyn` and `csharp_ls` require the .NET SDK 10 to work properly with Razor.
        Using the most recent SDK version is strongly recommended.
        :::

        :::{.tip}
        There is a way to avoid always specifying _dotnet-sdk_10_ inside devshells, even when a project targets _dotnet-sdk_8_. You can achieve this by adding the following **Lua** configuration to your **NVF** setup (for example, via `luaConfigRC`):

          ```lua
          vim.lsp.config('roslyn', {
              cmd = vim.list_extend(
                  { "$${pkgs.lib.getExe (with pkgs.dotnetCorePackages;
                  combinePackages [
                  sdk_10_0
                  sdk_9_0
                  sdk_8_0
                  ])}" },
                  vim.list_slice(vim.lsp.config.roslyn.cmd, 2)
                  )
              })
        ```
          This configuration overrides only the first argument of the Roslyn LSP command (the `dotnet` executable), replacing it with a `dotnet` binary built from a combined package that includes SDK versions 10, 9, and 8. Additional SDK versions can be added if needed.

          This approach is not a perfect solution. You may encounter issues if your project requires a specific patch version (for example, `8.0.433`) but the combined package only provides an earlier version (such as `8.0.300`). While this usually does not cause major problems, it is something to be aware of when using this setup.
        :::

        ::: {.warning}
        At the moment, only `roslyn` provides full Razor support.
        `csharp_ls` is limited to `.cshtml` files.
        :::
      '';

      treesitter = {
        enable = mkEnableOption "C# treesitter" // {default = config.vim.languages.enableTreesitter;};
        csPackage = mkGrammarOption pkgs "c_sharp";
        razorPackage = mkGrammarOption pkgs "razor";
      };

      lsp = {
        enable =
          mkEnableOption "C# language support" // {default = config.vim.lsp.enable;};
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
      vim.treesitter.grammars = with cfg.treesitter; [csPackage razorPackage];
    })

    (mkIf cfg.lsp.enable {
      vim = {
        startPlugins = concatMap (server: extraServerPlugins.${server}) cfg.lsp.servers;
        luaConfigRC.razorFileTypes =
          /*
          lua
          */
          ''
            -- Set unkown file types!
            vim.filetype.add {
              extension = {
                razor = "razor",
                cshtml = "razor",
              },
            }
          '';
        lsp.servers =
          mapListToAttrs (name: {
            inherit name;
            value = servers.${name};
          })
          cfg.lsp.servers;
      };
    })
  ]);
}
