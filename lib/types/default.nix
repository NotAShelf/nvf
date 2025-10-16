args: let
  typesDag = import ./dag.nix args;
  typesPlugin = import ./plugins.nix args;
  typesLanguage = import ./languages.nix args;
  customTypes = import ./custom.nix args;
in {
  inherit (typesDag) dagOf;
  inherit (typesPlugin) pluginsOpt extraPluginType mkPluginSetupOption luaInline pluginType borderType;
  inherit (typesLanguage) diagnostics mkGrammarOption;
  inherit (customTypes) char hexColor mergelessListOf singleOrListOf;
}
