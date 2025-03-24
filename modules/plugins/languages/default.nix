{lib, ...}: let
  inherit (lib.nvim.languages) mkEnable;
in {
  imports = [
    ./asm.nix
    ./astro.nix
    ./bash.nix
    ./cue.nix
    ./dart.nix
    ./clang.nix
    ./csharp.nix
    ./css.nix
    ./dart.nix
    ./elixir.nix
    ./gleam.nix
    ./go.nix
    ./hcl.nix
    ./helm.nix
    ./kotlin.nix
    ./html.nix
    ./haskell.nix
    ./hcl.nix
    ./html.nix
    ./java.nix
    ./julia.nix
    ./kotlin.nix
    ./lua.nix
    ./markdown.nix
    ./nim.nix
    ./nix.nix
    ./nu.nix
    ./ocaml.nix
    ./odin.nix
    ./php.nix
    ./python.nix
    ./r.nix
    ./ruby.nix
    ./rust.nix
    ./scala.nix
    ./sql.nix
    ./svelte.nix
    ./tailwind.nix
    ./terraform.nix
    ./tex
    ./ts.nix
    ./typst.nix
    ./vala.nix
    ./wgsl.nix
    ./yaml.nix
    ./zig.nix
  ];

  options.vim.languages = {
    enableLSP = mkEnable "LSP";
    enableDAP = mkEnable "Debug Adapter";
    enableTreesitter = mkEnable "Treesitter";
    enableFormat = mkEnable "Formatting";
    enableExtraDiagnostics = mkEnable "extra diagnostics";
  };
}
