{
  inputs,
  lib,
  ...
}: let
  typesDag = import ./dag.nix {inherit lib;};
  typesPlugin = import ./plugins.nix {inherit inputs lib;};
  typesLanguage = import ./languages.nix {inherit lib;};
  typesCustom = import ./custom.nix {inherit lib;};
  typesTheme = import ./theme.nix {inherit lib;};
in {
  inherit (typesDag) dagOf;
  inherit (typesPlugin) pluginsOpt extraPluginType mkPluginSetupOption luaInline pluginType borderType;
  inherit (typesLanguage) diagnostics mkGrammarOption;
  inherit (typesCustom) anythingConcatLists char;
  inherit (typesTheme) hexColorType;
}
