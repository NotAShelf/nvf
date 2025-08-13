{lib, ...}: let
  inherit (lib.modules) mkRenamedOptionModule;
  inherit (lib.nvim.languages) mkEnable;
in {
  imports = [
    ./asm.nix
    ./astro.nix
    ./bash.nix
    ./cue.nix
    ./dart.nix
    ./clang.nix
    ./clojure.nix
    ./css.nix
    ./elixir.nix
    ./fsharp.nix
    ./gleam.nix
    ./go.nix
    ./hcl.nix
    ./helm.nix
    ./kotlin.nix
    ./html.nix
    ./haskell.nix
    ./java.nix
    ./json.nix
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
    ./wgsl.nix
    ./yaml.nix
    ./ruby.nix
    ./just.nix

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
