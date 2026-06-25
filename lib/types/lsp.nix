{lib}: let
  inherit (lib.options) mkEnableOption;

  mkLspPresetEnableOption = option: display: fileTypes:
    mkEnableOption ''
      the ${display} Language Server.
      Default `filetypes = ${lib.generators.toPretty {} fileTypes}`.
      Use {option}`vim.lsp.servers.${option}` for customization
    '';
in {
  inherit mkLspPresetEnableOption;
}
