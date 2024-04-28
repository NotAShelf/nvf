{lib, ...}: let
  inherit (lib.modules) mkAliasOptionModule;
in {
  imports = [
    (mkAliasOptionModule ["vim" "spellcheck" "vim-dirtytalk" "enable"] ["vim" "spellcheck" "programmingWordlist" "enable"])
  ];
}
