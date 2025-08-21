# Make the behaviour of `nix-shell` consistent with the one of `nix develop`
# by returning the default devShell output from the flake. This is useful when
# I do not want to work with direnv, or simply need backwards compatibility.
{system ? builtins.currentSystem}: let
  nvf = import ./.;
in
  nvf.devShells.${system}.default
