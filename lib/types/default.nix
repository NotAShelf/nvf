{lib}: let
  typesDag = import ./dag.nix {inherit lib;};
  typesPlugin = import ./plugins.nix {inherit lib;};
  typesLanguage = import ./languages.nix {inherit lib;};
in {
  inherit (typesDag) dagOf;
  inherit (typesPlugin) pluginsOpt extraPluginType mkPluginSetupOption luaInline;
  inherit (typesLanguage) diagnostics mkGrammarOption;
}
