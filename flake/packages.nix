{inputs, ...}: {
  perSystem = {
    self',
    system,
    config,
    pkgs,
    ...
  }: let
    docs = import ../docs {
      inherit pkgs;
      nmdSrc = inputs.nmd;
    };
  in {
    packages =
      {
        # Documentation
        docs = docs.manual.html;
        docs-html = docs.manual.html;
        docs-manpages = docs.manPages;
        docs-json = docs.options.json;

        docs-html-wrapped = pkgs.writeScriptBin "docs-html-wrapped" ''
          #!${pkgs.stdenv.shell}
          # use xdg-open to open the docs in the browser
          ${pkgs.xdg_utils}/bin/xdg-open ${docs.manual.html}
        '';

        # nvim configs
        nix = config.legacyPackages.neovim-nix;
        maximal = config.legacyPackages.neovim-maximal;
        default = config.legacyPackages.neovim-nix;
      }
      // (
        if !(builtins.elem system ["aarch64-darwin" "x86_64-darwin"])
        then {tidal = config.legacyPackages.neovim-tidal;}
        else {}
      );
  };
}
