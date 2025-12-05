{lib, ...}: let
  inherit (lib.modules) mkRenamedOptionModule;
  inherit (lib.nvim.languages) mkEnable;
in {
  imports = [
    ./asm.nix
    ./astro.nix
    ./bash.nix
    ./clang.nix
    ./clojure.nix
    ./csharp.nix
    ./css.nix
    ./cue.nix
    ./dart.nix
    ./elixir.nix
    ./fsharp.nix
    ./gleam.nix
    ./go.nix
    ./haskell.nix
    ./hcl.nix
    ./helm.nix
    ./html.nix
    ./java.nix
    ./json.nix
    ./julia.nix
    ./just.nix
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
    ./qml.nix
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

    # This is now a hard deprecation.
    (mkRenamedOptionModule ["vim" "languages" "enableLSP"] ["vim" "lsp" "enable"])
  ];

  options.vim.languages = {
    # Those are still managed by plugins, and should be enabled here.
    enableDAP = mkEnable "Debug Adapter";
    enableTreesitter = mkEnable "Treesitter";
    enableFormat = mkEnable "Formatting";
    enableExtraDiagnostics = mkEnable "extra diagnostics";
  };
}
