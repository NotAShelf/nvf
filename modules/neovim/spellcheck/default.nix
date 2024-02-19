{
  lib,
  config,
  ...
}: let
  inherit (builtins) concatStringsSep;
  inherit (lib) optionalString optionals mkIf nvim;

  cfg = config.vim;
in {
  imports = [./options.nix];
  config = mkIf cfg.spellChecking.enable {
    vim = {
      startPlugins = optionals cfg.spellChecking.enableProgrammingWordList ["vim-dirtytalk"];
      configRC.spellcheck = nvim.dag.entryAfter ["basic"] ''
        ${optionalString cfg.spellChecking.enable ''
          set spell
          set spelllang=${concatStringsSep "," cfg.spellChecking.languages}${optionalString cfg.spellChecking.enableProgrammingWordList ",programming"}
        ''}
      '';
    };
  };
}
