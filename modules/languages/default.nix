{lib, ...}: let
  inherit (lib.nvim.languages) mkEnable;
in {
  imports = [
    ./markdown
    ./tidal
    ./dart
    ./elixir
    ./bash

    ./clang.nix
    ./go.nix
    ./nix.nix
    ./python.nix
    ./rust.nix
    ./sql.nix
    ./ts.nix
    ./zig.nix
    ./html.nix
    ./svelte.nix
    ./java.nix
    ./lua.nix
    ./php.nix
    ./terraform.nix
  ];

  options.vim.languages = {
    enableLSP = mkEnable "LSP";
    enableDAP = mkEnable "Debug Adapter";
    enableTreesitter = mkEnable "Treesitter";
    enableFormat = mkEnable "Formatting";
    enableExtraDiagnostics = mkEnable "extra diagnostics";
  };
}
