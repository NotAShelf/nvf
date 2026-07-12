{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) nullOr str;
in {
  config.vim.lib = {
    mkMappingOption = description: default:
      mkOption {
        type = nullOr str;
        default =
          if config.vim.vendoredKeymaps.enable
          then default
          else null;
        inherit description;
      };

    mkLanguageLspEnableOption = {
      option,
      display,
      extra ? "",
    }:
      mkEnableOption ''
        LSP support for ${display}.
        Select the language servers you want in {option}`vim.language.${option}.servers`.

        ${extra}

        Use [`vim.lsp.servers.<lsp_name>`](`vim.lsp.servers`) for customization
        of each language server.
      ''
      // {
        default = config.vim.lsp.enable;
        defaultText = literalExpression "config.vim.lsp.enable";
      };
  };
}
