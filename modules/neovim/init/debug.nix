{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.strings) optionalString;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) path enum nullOr;
  inherit (lib.nvim.dag) entryAfter;

  cfg = config.vim.debugMode;
in {
  options.vim = {
    debugMode = {
      enable = mkEnableOption "debug mode";
      level = mkOption {
        type = enum [2 3 4 5 8 9 11 12 13 14 15 16];
        default = 16;
        description = ''
          Set verbosity level of Neovim while debug mode is enabled.

          Value must be be one of the levels expected by Neovim's
          [`verbose` option](https://neovim.io/doc/user/options.html#'verbose')
        '';
      };

      logFile = mkOption {
        type = nullOr path;
        default = null;
        description = ''
          Set the log file that will be used to store verbose messages
          set by the `verbose` option.
        '';
      };
    };
  };

  config.vim = mkIf cfg.enable {
    luaConfigRC.debug-mode = entryAfter ["basic"] ''
      -- Debug mode settings
      vim.o.verbose = ${toString cfg.level},

      ${optionalString (cfg.logFile != null) ''
        -- Set verbose log file
        vim.o.verbosefile = ${cfg.logFile},
      ''}
    '';
  };
}
