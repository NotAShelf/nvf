{lib}: {
  modules = import ./modules.nix {inherit lib;};
  dag = import ./dag.nix {inherit lib;};
  types = import ./types {inherit lib;};
  languages = import ./languages.nix {inherit lib;};
  lua = import ./lua.nix {inherit lib;};
  vim = import ./vim.nix {inherit lib;};
}
