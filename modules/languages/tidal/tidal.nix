{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  options.vim.tidal = {
    enable = mkEnableOption "Enable tidalcycles tools and plugins";

    flash = mkOption {
      description = ''When sending a paragraph or a single line, vim-tidal will "flash" the selection for some milliseconds'';
      type = types.int;
      default = 150;
    };

    openSC = mkOption {
      description = "Automatically run the supercollider CLI, sclang, alongside the Tidal GHCI terminal.";
      type = types.bool;
      default = true;
    };
  };
}
