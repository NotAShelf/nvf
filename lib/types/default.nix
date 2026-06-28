{
  lib,
  self,
}: let
  inherit (lib) concatMap optionalString concatStringsSep isBool isList head any filter all attrByPath;
  inherit (lib.generators) toPretty;
  inherit (lib.options) mkOption;
  inherit (lib.types) mkOptionType;

  mkTracedEnableOption = {
    config,
    option,
    description,
    extraTraces ? _location: _definitions: [],
  }:
    mkOption {
      default = false;
      inherit description;
      type = mkOptionType {
        name = "bool";
        description = "boolean";
        descriptionClass = "noun";
        check = value: isBool value || (isList value && all (element: element ? value && element ? src) value);
        merge = location: definitions: let
          normalizedDefinitions = map (definition:
            if isBool definition.value
            then {
              inherit (definition) value file;
              srcs = [];
              isPlain = true;
            }
            else {
              value = head (map (element: element.value) definition.value);
              srcs = map (element: element.src) definition.value;
              inherit (definition) file;
              isPlain = false;
            })
          definitions;

          hasTrueValue = any (definition: definition.value == true) normalizedDefinitions;
          hasFalseValue = any (definition: definition.value == false) normalizedDefinitions;

          trueDefinitionFiles = map (definition: definition.file) (filter (definition: definition.value == true && definition.isPlain) normalizedDefinitions);
          falseDefinitionFiles = map (definition: definition.file) (filter (definition: definition.value == false && definition.isPlain) normalizedDefinitions);

          nvfEnabledSourceFiles = concatMap (definition:
            if definition.value == true && !definition.isPlain
            then definition.srcs
            else [])
          normalizedDefinitions;
          nvfDisabledSourceFiles = concatMap (definition:
            if definition.value == false && !definition.isPlain
            then definition.srcs
            else [])
          normalizedDefinitions;
        in
          if hasTrueValue && hasFalseValue
          then
            throw (concatStringsSep "\n" (filter (s: s != "") ([
                "The Option `${concatStringsSep "." option}' has conflicting definitions."

                (optionalString (trueDefinitionFiles != []) ''
                  Enabled by:
                  ${concatStringsSep "\n" (map (file: "- ${file}") trueDefinitionFiles)}
                '')

                (optionalString (falseDefinitionFiles != []) ''
                  Disabled by:
                  ${concatStringsSep "\n" (map (file: "- ${file}") falseDefinitionFiles)}
                '')

                (optionalString (nvfEnabledSourceFiles != []) ''
                  Enabled via nvf modules:
                  ${concatStringsSep "\n" (map (source: "- `${concatStringsSep "." source} = ${toPretty {multiline = false;} (attrByPath source null config)}`") nvfEnabledSourceFiles)}
                '')

                (optionalString (nvfDisabledSourceFiles != []) ''
                  Disabled via nvf modules:
                  ${concatStringsSep "\n" (map (source: "- `${concatStringsSep "." source} = ${toPretty {multiline = false;} (attrByPath source null config)}`") nvfDisabledSourceFiles)}
                '')
              ]
              ++ (extraTraces location definitions))))
          else (head normalizedDefinitions).value;
      };
    };

  typesDag = import ./dag.nix {inherit lib;};
  typesPlugin = import ./plugins.nix {inherit lib self;};
  typesLanguage = import ./languages.nix {inherit lib;};
  typesLsp = import ./lsp.nix {inherit lib mkTracedEnableOption;};
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
