{lib, ...}: let
  inherit (lib.modules) mkRemovedOptionModule;
in {
  imports = [
    # 2024-06-06
    (mkRemovedOptionModule ["vim" "languages" "elixir"] ''
      Elixir language support has been removed as of 2024-06-06 as it was long unmaintained. If
      you dependend on this language support, please consider contributing to its maintenance.
    '')

    (mkRemovedOptionModule ["vim" "tidal"] ''
      Tidalcycles language support has been removed as of 2024-06-06 as it was long unmaintained. If
      you depended on this functionality, please open an issue.
    '')
  ];
}
