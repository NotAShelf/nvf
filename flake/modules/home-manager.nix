# Home Manager module
{
  inputs,
  lib,
}: {
  config,
  pkgs,
  ...
}: let
  inherit (inputs.self) packages;
  inherit (lib) maintainers;
  inherit (lib.modules) mkIf mkAliasOptionModule;
  inherit (lib.lists) optional;
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.types) anything bool submoduleWith;

  cfg = config.programs.nvf;

  nvfPkgs = import inputs.nixpkgs {inherit (pkgs) system;};

  nvfModule = submoduleWith {
    description = "Nvf module";
    class = "nvf";
    specialArgs = {
      pkgs = nvfPkgs;
      inherit lib inputs;
    };
    modules = import ../../modules/modules.nix {
      pkgs = nvfPkgs;
      inherit lib;
    };
  };
in {
  imports = [
    (mkAliasOptionModule ["programs" "neovim-flake"] ["programs" "nvf"])
  ];

  meta.maintainers = with maintainers; [NotAShelf];

  options.programs.nvf = {
    enable = mkEnableOption "nvf, the extensible neovim configuration wrapper";

    enableManpages = mkOption {
      type = bool;
      default = false;
      description = "Whether to enable manpages for nvf.";
    };

    defaultEditor = mkOption {
      type = bool;
      default = false;
      description = ''
        Whether to set `nvf` as the default editor.

        This will set the `EDITOR` environment variable as `nvim`
        if set to true.
      '';
    };

    finalPackage = mkOption {
      type = anything;
      visible = false;
      readOnly = true;
      description = ''
        The built nvf package, wrapped with the user's configuration.
      '';
    };

    settings = mkOption {
      type = nvfModule;
      default = {};
      description = "Attribute set of nvf preferences.";
      example = literalExpression ''
        {
          vim.viAlias = false;
          vim.vimAlias = true;
          vim.lsp = {
            enable = true;
            formatOnSave = true;
            lightbulb.enable = true;
            lspsaga.enable = false;
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
    programs.nvf.finalPackage = cfg.settings.vim.build.finalPackage;

    home = {
      sessionVariables = mkIf cfg.defaultEditor {EDITOR = "nvim";};
      packages =
        [cfg.finalPackage]
        ++ optional cfg.enableManpages packages.${pkgs.stdenv.system}.docs-manpages;
    };
  };
  _file = ./home-manager.nix;
}
