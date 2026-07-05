{lib}: let
  inherit (lib.options) mkEnableOption;

  mkLspPresetEnableOption = {
    option,
    display,
    defaultFiletypes ? [],
    extra ? "",
  }:
    mkEnableOption ''
      the ${display} Language Server.
      Default `filetypes = ${lib.generators.toPretty {} defaultFiletypes}`.

      ${extra}

      Use {option}`vim.lsp.servers.${option}` for customization
    '';
in {
  inherit mkLspPresetEnableOption;
}
