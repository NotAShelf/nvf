{
  lib,
  self,
}: let
  typesDag = import ./dag.nix {inherit lib;};
  typesPlugin = import ./plugins.nix {inherit lib self;};
  typesLanguage = import ./languages.nix {inherit lib;};
  typesLsp = import ./lsp.nix {inherit lib;};
  typesDiagnostics = import ./diagnostics.nix {inherit lib;};
  customTypes = import ./custom.nix {inherit lib;};
in {
  inherit (typesDag) dagOf;
  inherit (typesPlugin) pluginsOpt extraPluginType mkPluginSetupOption luaInline pluginType borderType;
  inherit (typesLanguage) mkGrammarOption mkTreesitterGrammarOption;
  inherit (typesLsp) mkLspPresetEnableOption;
  inherit (typesDiagnostics) mkDiagnosticsPresetEnableOption;
  inherit (customTypes) char hexColor mergelessListOf deprecatedSingleOrListOf enumWithRename;
}
