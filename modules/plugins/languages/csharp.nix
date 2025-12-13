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

  # roslyn is the official language server and the most feature-rich
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
      root_marks = [".sln" ".csproj"];
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
      root_marks = [".sln" ".csproj"];
      init_options = {
        AutomaticWorkspaceInit = true;
      };
    };

    roslyn = {
      # NOTE: cmd is set by roslyn-nvim!
      filetypes = ["cs" "razor" "cshtml"];
      root_marks = [".sln" ".csproj"];
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
      enable = mkEnableOption "C# language support. It requires .NET sdk 10";

      treesitter = {
        enable = mkEnableOption "C#/razor treesitter" // {default = config.vim.languages.enableTreesitter;};
        csPackage = mkGrammarOption pkgs "c-sharp";
        razorPackage = mkGrammarOption pkgs "razor";
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
      vim.treesitter.grammars = [cfg.treesitter.csPackage cfg.treesitter.razorPackage];
    })

    (mkIf (cfg.lsp.enable && lib.elem "roslyn" cfg.lsp.servers) {
      vim.luaConfigRC.roslyn-path = ''
        -- NOTE: this is required by roslyn-nvim to find roslyn
        vim.env.PATH = vim.env.PATH .. ":${pkgs.roslyn-ls}/bin"

        -- NOTE: this is required by roslyn-nvim to find .razorExtension folder
        -- roslyn-nvim looks for .razorExtension folder using this logic!
        -- take a look at https://github.com/seblyng/roslyn.nvim/blob/main/lua/roslyn/health.lua
        local razor_extensions_path = "${pkgs.vscode-extensions.ms-dotnettools.csharp}/share/vscode/extensions/ms-dotnettools.csharp/.razorExtension"

        -- Function to check if path exists (including symlinks)
        local function path_exists(path)
            local stat = vim.uv.fs_lstat(path)
            return stat ~= nil
        end

        -- Function to create symlink
        local function create_razor_symlink()
            if not razor_extensions_path or razor_extensions_path == "" then
                vim.notify("razor_extensions_path is not set", vim.log.levels.WARN)
                return
            end

            -- Check if source path exists
            if vim.fn.isdirectory(razor_extensions_path) == 0 then
                vim.notify("Source path does not exist: " .. razor_extensions_path, vim.log.levels.ERROR)
                return
            end

            -- Get mason path
            vim.env.MASON = vim.fn.expand("~/.local/share/nvf/mason")
            local expanded_mason = vim.fn.expand("$MASON")
            local mason = expanded_mason == "$MASON"
                and vim.fs.joinpath(vim.fn.stdpath("data"), "mason")
                or expanded_mason
            local mason_packages = vim.fs.joinpath(mason, "packages")

            -- Define target paths
            local targets = {
                vim.fs.joinpath(mason_packages, "roslyn", "libexec", ".razorExtension"),
                vim.fs.joinpath(mason_packages, "roslyn-unstable", "libexec", ".razorExtension"),
            }

            -- Create symlinks for each target
            for _, target in ipairs(targets) do
                local parent_dir = vim.fn.fnamemodify(target, ":h")

                -- Check if parent directory exists
                if vim.fn.isdirectory(parent_dir) == 1 then
                    -- Remove existing symlink or directory
                    if path_exists(target) then
                        vim.fn.delete(target, "rf")
                    end

                    -- Create symlink
                    local success = vim.uv.fs_symlink(razor_extensions_path, target, { dir = true })

                    if not success then
                        vim.notify("Failed to create symlink for .razorExtension: " .. target, vim.log.levels.ERROR)
                    end
                end
            end
        end

        -- Run the function
        create_razor_symlink()
      '';
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
