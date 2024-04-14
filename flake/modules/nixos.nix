# Home Manager module
packages: inputs: {
  config,
  pkgs,
  lib ? pkgs.lib,
  ...
}: let
  inherit (lib) maintainers;
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.types) attrsOf anything;

  cfg = config.programs.neovim-flake;
  inherit (import ../../configuration.nix inputs) neovimConfiguration;

  builtPackage = neovimConfiguration {
    inherit pkgs;
    modules = [cfg.settings];
  };
in {
  meta.maintainers = with maintainers; [NotAShelf];

  options.programs.neovim-flake = {
    enable = mkEnableOption "neovim-flake, the extensible neovim-wrapper";
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
    environment.systemPackages = [builtPackage];
  };
}
