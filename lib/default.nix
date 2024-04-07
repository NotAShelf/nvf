{lib}: {
  types = import ./types {inherit lib;};
  binds = import ./binds.nix {inherit lib;};
  dag = import ./dag.nix {inherit lib;};
  languages = import ./languages.nix {inherit lib;};
  lua = import ./lua.nix {inherit lib;};
  vim = import ./vim.nix;
}
