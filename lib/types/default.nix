args: {
  inherit (import ./dag.nix args) dagOf;
  inherit (import ./plugins.nix args) pluginsOpt extraPluginType mkPluginSetupOption luaInline pluginType borderType;
  inherit (import ./languages.nix args) diagnostics mkGrammarOption;
  inherit (import ./custom.nix args) char hexColor mergelessListOf singleOrListOf;
}
