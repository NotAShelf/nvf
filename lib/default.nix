{
  self,
  inputs,
  lib,
  ...
}: {
  types = import ./types {inherit lib self;};
  config = import ./config.nix {inherit lib;};
  binds = import ./binds.nix {inherit lib;};
  dag = import ./dag.nix {inherit lib;};
  languages = import ./languages.nix {inherit lib;};
  lists = import ./lists.nix {inherit lib;};
  attrsets = import ./attrsets.nix {inherit lib;};
  lua = import ./lua.nix {inherit lib;};
  neovimConfiguration = import ../modules {inherit self inputs lib;};
}
