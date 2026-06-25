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

  cfg = config.vim.lsp.presets.fsautocomplete;
in {
  options.vim.lsp.presets.fsautocomplete = {
    enable = mkLspPresetEnableOption "fsautocomplete" "F# Autocomplete" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.fsautocomplete = {
      enable = true;
      cmd = [(getExe pkgs.fsautocomplete) "--adaptive-lsp-server-enabled"];
      root_dir = mkLuaInline ''
        function(bufnr, on_dir)
          on_dir(vim.fs.root(bufnr, function(name, path)
            return name == ".git" or name:match("%.sln$") or name:match("%.fsproj$")
          end))
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
}
