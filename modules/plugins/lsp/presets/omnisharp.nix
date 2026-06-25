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

  cfg = config.vim.lsp.presets.omnisharp;
in {
  # HACK: this server should be named `omnisharp-roslyn`, but the extension `omnisharp-extended-lsp-nvim` only works if it is named `omnisharp`
  options.vim.lsp.presets.omnisharp = {
    enable = mkLspPresetEnableOption "omnisharp" "OmniSharp Roslyn" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.omnisharp = {
      cmd = mkLuaInline ''
        {
          '${getExe pkgs.omnisharp-roslyn}',
          '-z', -- https://github.com/OmniSharp/omnisharp-vscode/pull/4300
          '--hostPID',
          tostring(vim.fn.getpid()),
          'DotNet:enablePackageRestore=false',
          '--encoding',
          'utf-8',
          '--languageserver',
        }
      '';
      root_dir = mkLuaInline ''
        function(bufnr, on_dir)
            local fname = vim.api.nvim_buf_get_name(bufnr)
            on_dir(
              util.root_pattern '*.slnx'(fname)
                or util.root_pattern '*.sln'(fname)
                or util.root_pattern '*.csproj'(fname)
                or util.root_pattern 'omnisharp.json'(fname)
                or util.root_pattern 'function.json'(fname)
            )
          end
      '';
      init_options = {};
      capabilities = {
        workspace = {
          workspaceFolders = false; # https://github.com/OmniSharp/omnisharp-roslyn/issues/909
        };
      };
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
  };
}
