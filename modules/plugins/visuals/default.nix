{lib, ...}: let
  inherit (lib.modules) mkRemovedOptionModule;
in {
  imports = [
    (mkRemovedOptionModule ["vim" "visuals" "enable"] ''
      As top-level toggles are being deprecated, you are encouraged to handle plugin
      toggles under individual options.
    '')

    ./cellular-automaton
    ./cinnamon-nvim
    ./fidget-nvim
    ./highlight-undo
    ./hlargs-nvim
    ./indent-blankline
    ./nvim-cursorline
    ./nvim-scrollbar
    ./nvim-web-devicons
    ./rainbow-delimiters
    ./tiny-devicons-auto-colors
  ];
}
