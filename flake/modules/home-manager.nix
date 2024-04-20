# Home Manager module
packages: inputs: {
  config,
  pkgs,
  lib ? pkgs.lib,
  ...
}: let
  inherit (lib) maintainers;
  inherit (lib.modules) mkIf;
  inherit (lib.lists) optional;
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.types) attrsOf anything bool;

  cfg = config.programs.neovim-flake;
  inherit (import ../../configuration.nix inputs) neovimConfiguration;

  neovimConfigured = neovimConfiguration {
    inherit pkgs;
    modules = [cfg.settings];
  };
in {
  meta.maintainers = with maintainers; [NotAShelf];

  options.programs.neovim-flake = {
    enable = mkEnableOption "neovim-flake, the extensible neovim configuration wrapper";

    enableManpages = mkOption {
      type = bool;
      default = false;
      description = "Whether to enable manpages for neovim-flake.";
    };

    defaultEditor = mkOption {
      type = bool;
      default = false;
      description = ''
        Whether to set `neovim-flake` as the default editor.

        This will set the `EDITOR` environment variable as `nvim`
        if set to true.
      '';
    };

    finalPackage = mkOption {
      type = anything;
      visible = false;
      readOnly = true;
      description = ''
        The built neovim-flake package, wrapped with the user's configuration.
      '';
    };

    settings = mkOption {
      type = attrsOf anything;
      default = {};
      description = "Attribute set of neovim-flake preferences.";
      example = literalExpression ''
        {
          vim.viAlias = false;
          vim.vimAlias = true;
          vim.lsp = {
            enable = true;
            formatOnSave = true;
            lightbulb.enable = true;
            lspsaga.enable = false;
            nvimCodeActionMenu.enable = true;
            trouble.enable = true;
            lspSignature.enable = true;
            rust.enable = false;
            nix = true;
          };
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.neovim-flake.finalPackage = neovimConfigured.neovim;

    home = {
      sessionVariables = mkIf cfg.defaultEditor {EDITOR = "nvim";};
      packages =
        [cfg.finalPackage]
        ++ optional cfg.enableManpages packages.${pkgs.stdenv.system}.docs-manpages;
    };
  };
}
