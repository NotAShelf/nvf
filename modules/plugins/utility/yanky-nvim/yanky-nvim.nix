{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) enum;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.utility.yanky-nvim = {
    enable = mkEnableOption ''
      improved Yank and Put functionalities for Neovim  [yanky-nvim]
    '';

    setupOpts = mkPluginSetupOption "yanky-nvim" {
      ring.storage = mkOption {
        type = enum ["shada" "sqlite" "memory"];
        default = "shada";
        example = "sqlite";
        description = ''
          storage mode for ring values.

          - **shada**: this will save pesistantly using Neovim ShaDa feature.
            This means that history will be persisted between each session of Neovim.
          - **memory**: each Neovim instance will have his own history and it will be
            lost between sessions.
          - **sqlite**: more reliable than `shada`, requires `sqlite.lua` as a dependency.
            nvf will add this dependency to `PATH` automatically.
        '';
      };
    };
  };
}
