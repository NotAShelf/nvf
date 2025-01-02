{lib, ...}: let
  inherit (lib.nvim.languages) mkEnable;
in {
  imports = [
    ./asm.nix
    ./astro.nix
    ./bash.nix
    ./dart.nix
    ./clang.nix
    ./css.nix
    ./elixir.nix
    ./gleam.nix
    ./go.nix
    ./hcl.nix
    ./kotlin.nix
    ./html.nix
    ./haskell.nix
    ./java.nix
    ./lua.nix
    ./markdown.nix
    ./nim.nix
    ./vala.nix
    ./nix.nix
    ./ocaml.nix
    ./php.nix
    ./python.nix
    ./r.nix
    ./rust.nix
    ./scala.nix
    ./sql.nix
    ./svelte.nix
    ./tailwind.nix
    ./terraform.nix
    ./ts.nix
    ./typst.nix
    ./zig.nix
    ./csharp.nix
    ./julia.nix
    ./nu.nix
    ./odin.nix
  ];

  options.vim.languages = {
    enableLSP = mkEnable "LSP";
    enableDAP = mkEnable "Debug Adapter";
    enableTreesitter = mkEnable "Treesitter";
    enableFormat = mkEnable "Formatting";
    enableExtraDiagnostics = mkEnable "extra diagnostics";
  };
}
