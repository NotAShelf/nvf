{lib}: let
  inherit (lib.generators) toPretty;
  inherit (lib.options) mkOption;
  inherit (lib.strings) removeSuffix optionalString;
  inherit (lib.types) bool;

  mkLspPresetEnableOption = option: display: fileTypes:
    mkLspPresetEnableOptionWithDesc option display fileTypes "";

  mkLspPresetEnableOptionWithDesc = option: display: fileTypes: description:
    mkOption {
      type = bool;
      default = false;
      description = removeSuffix "\n" (''
          The ${display} Language Server.
          Default `filetypes = ${toPretty {} fileTypes}`.
          Use {option}`vim.lsp.servers.${option}` for customization.
        ''
        + optionalString (description != "") ''

          ${description}
        '');
    };
in {
  inherit mkLspPresetEnableOption mkLspPresetEnableOptionWithDesc;
}
