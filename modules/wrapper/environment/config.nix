{
  config,
  lib,
  ...
}: let
  inherit (lib.attrsets) attrValues;

  cfg = config.vim;
in {
  config = {
    vim.startPlugins = map (x: x.package) (attrValues cfg.extraPlugins);
  };
}
