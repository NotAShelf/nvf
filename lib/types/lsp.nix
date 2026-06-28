{
  lib,
  mkTracedEnableOption,
}: let
  inherit (lib) optionalString;
  inherit (lib.generators) toPretty;

  mkLspPresetEnableOption = {
    config,
    option,
    display,
    fileTypes ? [],
    extraDescription ? "",
  }:
    mkTracedEnableOption {
      inherit config;
      option = ["vim" "lsp" "presets" option "enable"];
      description = ''
        Whether to enable the ${display} Language Server.
        Default `filetypes = ${toPretty {} fileTypes}`.
        Use {option}`vim.lsp.servers.${option}` for customization
        ${optionalString (extraDescription != "") "\n${extraDescription}"}
      '';
      extraTraces = _location: _definitions: [
        (optionalString config.vim.lsp.enable ''
          Note: `vim.lsp.enable` is set to true, which causes all enabled
                language modules to enable their default `lsp.servers`.
        '')
      ];
    };
in {
  inherit mkLspPresetEnableOption;
}
