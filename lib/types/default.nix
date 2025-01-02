{
  inputs,
  lib,
  ...
}: let
  typesDag = import ./dag.nix {inherit lib;};
  typesPlugin = import ./plugins.nix {inherit inputs lib;};
  typesLanguage = import ./languages.nix {inherit lib;};
  customTypes = import ./custom.nix {inherit lib;};
in {
  inherit (typesDag) dagOf;
  inherit (typesPlugin) pluginsOpt extraPluginType mkPluginSetupOption luaInline pluginType borderType;
  inherit (typesLanguage) diagnostics mkGrammarOption;
  inherit (customTypes) char hexColor mergelessListOf;
}
