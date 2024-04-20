{lib, ...}: let
  inherit (lib.modules) mkAliasOptionModule;
in {
  imports = [
    (mkAliasOptionModule ["vim" "spellcheck" "vim-dirtytalk" "enable"] ["vim" "spellChecking" "programmingWordlist" "enable"])
  ];
}
