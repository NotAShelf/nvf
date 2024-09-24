{
  inputs,
  lib,
  ...
}: {
  types = import ./types {inherit inputs lib;};

  config = import ./config.nix {inherit lib;};
  binds = import ./binds.nix {inherit lib;};
  dag = import ./dag.nix {inherit lib;};
  languages = import ./languages.nix {inherit lib;};
  lists = import ./lists.nix {inherit lib;};
  lua = import ./lua.nix {inherit lib;};
  neovimConfiguration = import ../modules {inherit inputs lib;};
}
