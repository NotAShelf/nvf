{
  inputs,
  lib,
  ...
}: let
  typesDag = import ./dag.nix {inherit lib;};
  typesPlugin = import ./plugins.nix {inherit inputs lib;};
  typesLanguage = import ./languages.nix {inherit lib;};
  typesTypes = import ./types.nix {inherit lib;};
in {
  inherit (typesDag) dagOf;
  inherit (typesPlugin) pluginsOpt extraPluginType mkPluginSetupOption luaInline pluginType borderType;
  inherit (typesLanguage) diagnostics mkGrammarOption;
  inherit (typesTypes) anythingConcatLists char hexColor;
}
