{
  inputs,
  self,
  ...
} @ args: {
  perSystem = {
    config,
    pkgs,
    lib,
    ...
  }: let
    inherit (lib.customisation) makeScope;
    inherit (lib.attrsets) isDerivation isAttrs concatMapAttrs;
    inherit (lib.strings) concatStringsSep;
    inherit (lib.filesystem) packagesFromDirectoryRecursive;

    # Entrypoint for nvf documentation and relevant packages.
    docs = import ../docs {inherit pkgs inputs lib;};

    # Helper function for creating demo configurations for nvf
    # TODO: make this more generic.
    buildPkg = maximal:
      (args.config.flake.lib.nvim.neovimConfiguration {
        inherit pkgs;
        modules = [(import ../configuration.nix maximal)];
      }).neovim;

    # This constructs a by-name overlay similar to the one found in Nixpkgs.
    # The goal is to automatically discover and packages found in pkgs/by-name
    # as long as they have a 'package.nix' in the package directory. We also
    # pass 'inputs' and 'pins' to all packages in the 'callPackage' scope, therefore
    # they are always available in the relevant 'package.nix' files.
    # ---
    # The logic is borrowed from drupol/pkgs-by-name-for-flake-parts, available
    # under the MIT license.
    flattenPkgs = separator: path: value:
      if isDerivation value
      then {
        ${concatStringsSep separator path} = value;
      }
      else if isAttrs value
      then concatMapAttrs (name: flattenPkgs separator (path ++ [name])) value
      else
        # Ignore the functions which makeScope returns
        {};

    inputsScope = makeScope pkgs.newScope (_: {
      inherit inputs;
      inherit (self) pins;
    });

    scopeFromDirectory = directory:
      packagesFromDirectoryRecursive {
        inherit directory;
        inherit (inputsScope) newScope callPackage;
      };

    legacyPackages = scopeFromDirectory ./pkgs/by-name;
  in {
    packages =
      (flattenPkgs "/" [] legacyPackages)
      // {
        inherit (docs.manual) htmlOpenTool;

        # Documentation
        docs = docs.manual.html;
        docs-html = docs.manual.html;
        docs-manpages = docs.manPages;
        docs-json = docs.options.json;
        docs-linkcheck = let
          site = config.packages.docs;
        in
          pkgs.testers.lycheeLinkCheck {
            inherit site;

            remap = {
              "https://notashelf.github.io/nvf/" = site;
            };

            extraConfig = {
              exclude = [];
              include_mail = true;
              include_verbatim = true;
            };
          };

        # Helper utility for building the HTML manual and opening it in the
        # browser with $BROWSER or using xdg-open as a fallback tool.
        # Adapted from Home-Manager, available under the MIT license.
        docs-html-wrapped = let
          xdg-open = lib.getExe' pkgs.xdg-utils "xdg-open";
          docs-html = docs.manual.html + /share/doc/nvf;
        in
          pkgs.writeShellScriptBin "docs-html-wrapped" ''
            set -euo pipefail

            if [[ ! -v BROWSER || -z $BROWSER ]]; then
              for candidate in xdg-open open w3m; do
              BROWSER="$(type -P $candidate || true)"
                if [[ -x $BROWSER ]]; then
                  break;
                fi
              done
            fi

            if [[ ! -v BROWSER || -z $BROWSER ]]; then
              echo "$0: unable to start a web browser; please set \$BROWSER"
              echo "$0: Trying xdg-open as a fallback"
              ${xdg-open} ${docs-html}/index.xhtml
            else
              echo "\$BROWSER is set. Attempting to open manual"
              exec "$BROWSER" "${docs-html}/index.xhtml"
            fi
          '';

        # Exposed neovim configurations
        nix = buildPkg false;
        maximal = buildPkg true;
        default = config.packages.nix;
      };
  };
}
