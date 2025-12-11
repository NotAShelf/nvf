{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption mkEnableOption mkPackageOption;
  inherit (lib.types) str submodule;
  inherit (lib.attrsets) mapAttrs mapAttrsToList filterAttrs;
  cfg = config.vim.clipboard;
in {
  options = {
    vim = {
      clipboard = {
        enable = mkEnableOption ''
          clipboard management for Neovim. Users may still choose to manage their
          clipboard through {option}`vim.options` should they wish to avoid using
          this module.
        '';

        registers = mkOption {
          type = str;
          default = "";
          example = "unnamedplus";
          description = ''
            The register to be used by the Neovim clipboard. Recognized types are:

            * unnamed: Vim will use the clipboard register `"*"` for all yank, delete,
              change and put operations which would normally go to the unnamed register.

            * unnamedplus: A variant of the "unnamed" flag which uses the clipboard register
            `"+"` ({command}`:h quoteplus`) instead of register `"*"` for all yank, delete,
            change and put operations which would normally go to the unnamed register.

            When `unnamed` and `unnamedplus` is included simultaneously as `"unnamed,unnamedplus"`,
            yank and delete operations (but not put) will additionally copy the text into register `"*"`.

            Please see  {command}`:h clipboard` for more details.

          '';
        };

        providers = mkOption {
          type = submodule {
            options = let
              clipboards = {
                # name = "package name";
                wl-copy = "wl-clipboard";
                xclip = "xclip";
                xsel = "xsel";
              };
            in
              mapAttrs (name: pname: {
                enable = mkEnableOption name;
                package = mkPackageOption pkgs pname {nullable = true;};
              })
              clipboards;
          };
          default = {};
          description = ''
            Clipboard providers for which packages will be added to nvf's
            {option}`extraPackages`. The `package` field may be set to `null`
            if related packages are already found in system packages to
            potentially reduce closure sizes.
          '';
        };
      };
    };
  };

  config = mkIf cfg.enable {
    vim = {
      options.clipboard = cfg.registers;
      extraPackages = mapAttrsToList (_: v: v.package) (
        filterAttrs (_: v: v.enable && v.package != null) cfg.providers
      );
    };
  };
}
