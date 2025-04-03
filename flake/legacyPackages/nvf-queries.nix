{
  vimUtils,
  version,
}:
vimUtils.buildVimPlugin {
  pname = "nvf-queries";
  inherit version;

  src = ./nvf-queries;
}
