{lib}: {
  dag = import ./dag.nix {inherit lib;};
  booleans = import ./booleans.nix {inherit lib;};
  types = import ./types {inherit lib;};
  languages = import ./languages.nix {inherit lib;};
  nmd = import ./nmd.nix;
  lua = import ./lua.nix {inherit lib;};
}
