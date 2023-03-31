# Home Manager module
{
  self,
  config,
  pkgs,
  lib ? pkgs.lib,
  ...
}: let
  cfg = config.programs.neovim-flake;
  set = self.packages.neovim-maximal {mainConfig = cfg.settings;};
in
  with lib; {
    meta.maintainers = [maintainers.notashelf];

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
