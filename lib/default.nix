{
  inputs,
  self,
}: final: let
  # Modeled after nixpkgs' lib.
  callLibs = file:
    import file {
      nvf-lib = final;
      inherit inputs self;
      inherit (inputs.nixpkgs) lib;
    };
in {
  types = callLibs ./types;
  config = callLibs ./config.nix;
  binds = callLibs ./binds.nix;
  dag = callLibs ./dag.nix;
  languages = callLibs ./languages.nix;
  lists = callLibs ./lists.nix;
  attrsets = callLibs ./attrsets.nix;
  lua = callLibs ./lua.nix;
  neovimConfiguration = callLibs ../modules;
}
