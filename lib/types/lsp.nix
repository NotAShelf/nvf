{lib}: let
  inherit (lib.options) mkOption;

  mkLspPresetEnableOption = option: display: fileTypes:
    mkLspPresetEnableOptionWithDesc option display fileTypes "";

  mkLspPresetEnableOptionWithDesc = option: display: fileTypes: description:
    mkOption {
      type = lib.types.bool;
      default = false;
      description = lib.removeSuffix "\n" (''
          The ${display} Language Server.
          Default `filetypes = ${lib.generators.toPretty {} fileTypes}`.
          Use {option}`vim.lsp.servers.${option}` for customization.
        ''
        + lib.optionalString (description != "") ''

          ${description}
        '');
    };
in {
  inherit mkLspPresetEnableOption mkLspPresetEnableOptionWithDesc;
}
