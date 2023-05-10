{lib, ...}:
with lib;
with builtins; {
  options.vim.utility.vim-wakatime = {
    enable = mkEnableOption "Enable vim-wakatime";
  };
}

