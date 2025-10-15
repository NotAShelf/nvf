{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;

  inherit (lib.lists) replicate;
  inherit
    (lib.strings)
    optionalString
    removeSuffix
    concatStrings
    stringAsChars
    concatMapStringsSep
    ;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (pkgs) writeTextFile;
  cfg = config.vim.snippets.luasnip;
  # LuaSnip freaks out if the indentation is wrong in snippets
  indent = n: s: let
    indentString = concatStrings (replicate n " ");
    sep = "\n" + indentString;
  in
    indentString
    + stringAsChars (c:
      if c == "\n"
      then sep
      else c) (removeSuffix "\n" s);
  customSnipmateSnippetFiles =
    mapAttrsToList (
      name: value:
        writeTextFile {
          name = "${name}.snippets";
          text =
            concatMapStringsSep "\n" (x: ''
              snippet ${x.trigger} ${x.description}
              ${indent 2 x.body}
            '')
            value;
          destination = "/snippets/${name}.snippets";
        }
    )
    cfg.customSnippets.snipmate;
in {
  config = mkIf cfg.enable {
    vim = {
      lazy.plugins.luasnip = {
        package = "luasnip";

        lazy = true;

        setupModule = "luasnip";
        inherit (cfg) setupOpts;

        after = cfg.loaders;
      };
      startPlugins = cfg.providers ++ customSnipmateSnippetFiles;
      autocomplete.nvim-cmp = mkIf config.vim.autocomplete.nvim-cmp.enable {
        sources = {luasnip = "[LuaSnip]";};
        sourcePlugins = ["cmp-luasnip"];
      };
      snippets.luasnip.loaders = ''
        ${optionalString (
          cfg.customSnippets.snipmate != {}
        ) "require('luasnip.loaders.from_snipmate').lazy_load()"}
        ${optionalString (
          config.vim.autocomplete.nvim-cmp.enable || config.vim.autocomplete.blink-cmp.friendly-snippets.enable
        ) "require('luasnip.loaders.from_vscode').lazy_load()"}
      '';
    };
  };
}
