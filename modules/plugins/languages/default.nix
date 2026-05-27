{lib, ...}: let
  inherit (lib.modules) mkRenamedOptionModule;
  inherit (lib.nvim.languages) mkEnable;
in {
  imports = [
    ./arduino.nix
    ./asm.nix
    ./astro.nix
    ./bash.nix
    ./clang.nix
    ./clojure.nix
    ./cmake.nix
    ./csharp.nix
    ./css.nix
    ./cue.nix
    ./dart.nix
    ./docker.nix
    ./elixir.nix
    ./elm.nix
    ./env.nix
    ./fish.nix
    ./fluent.nix
    ./fsharp.nix
    ./gettext.nix
    ./gleam.nix
    ./glsl.nix
    ./go.nix
    ./haskell.nix
    ./hcl.nix
    ./helm.nix
    ./html.nix
    ./java.nix
    ./jinja.nix
    ./jq.nix
    ./json.nix
    ./julia.nix
    ./just.nix
    ./kotlin.nix
    ./liquid.nix
    ./lua.nix
    ./make.nix
    ./markdown.nix
    ./nim.nix
    ./nix.nix
    ./nu.nix
    ./ocaml.nix
    ./odin.nix
    ./openscad.nix
    ./php.nix
    ./python.nix
    ./qml.nix
    ./r.nix
    ./ruby.nix
    ./rust.nix
    ./scala.nix
    ./scss.nix
    ./scss.nix
    ./sql.nix
    ./standard-ml.nix
    ./svelte.nix
    ./tera.nix
    ./terraform.nix
    ./tex.nix
    ./toml.nix
    ./tsx.nix
    ./twig.nix
    ./typescript.nix
    ./typst.nix
    ./vala.nix
    ./vhdl.nix
    ./vue.nix
    ./wgsl.nix
    ./xml.nix
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
