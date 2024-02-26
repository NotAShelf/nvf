# Home Manager module
packages: inputs: {
  pkgs,
  config,
  lib ? pkgs.lib,
  self,
  ...
}:
with lib; let
  cfg = config.programs.neovim-flake;
  inherit (import ../../configuration.nix inputs) neovimConfiguration;
  set = neovimConfiguration {
    inherit pkgs;
    modules = [cfg.settings];
  };
in {
  meta.maintainers = with maintainers; [NotAShelf];

  options.programs.neovim-flake = {
    enable = mkEnableOption "A NeoVim IDE with a focus on configurability and extensibility.";

    settings = mkOption {
      type = types.attrsOf types.anything;
      default = {};
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
      description = "Attribute set of neoflake preferences.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [set.neovim];
  };
}
