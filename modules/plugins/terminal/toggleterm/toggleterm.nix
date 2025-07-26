{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.nvim.binds) mkMappingOption;
  inherit (lib.types) nullOr str enum bool package either int;
  inherit (lib.modules) mkRenamedOptionModule;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline;
  inherit (lib.generators) mkLuaInline;
in {
  imports = [
    (mkRenamedOptionModule ["vim" "terminal" "toggleterm" "direction"] ["vim" "terminal" "toggleterm" "setupOpts" "direction"])
    (mkRenamedOptionModule ["vim" "terminal" "toggleterm" "enable_winbar"] ["vim" "terminal" "toggleterm" "setupOpts" "enable_winbar"])
  ];

  options.vim.terminal.toggleterm = {
    enable = mkEnableOption "toggleterm as a replacement to built-in terminal command";
    mappings = {
      open = mkOption {
        type = nullOr str;
        description = "The keymapping to open toggleterm";
        default = "<c-t>";
      };
    };

    setupOpts = mkPluginSetupOption "ToggleTerm" {
      direction = mkOption {
        type = enum ["horizontal" "vertical" "tab" "float"];
        default = "horizontal";
        description = "Direction of the terminal";
      };

      enable_winbar = mkOption {
        type = bool;
        default = false;
        description = "Enable winbar";
      };

      size = mkOption {
        type = either luaInline int;
        description = "Number or lua function which is passed to the current terminal";
        default = mkLuaInline ''
          function(term)
            if term.direction == "horizontal" then
              return 15
            elseif term.direction == "vertical" then
              return vim.o.columns * 0.4
            end
          end
        '';
      };
      winbar = {
        enabled = mkEnableOption "winbar in terminal" // {default = true;};
        name_formatter = mkOption {
          type = luaInline;
          description = "Winbar formatter function.";
          default = mkLuaInline ''
            function(term)
              return term.name
            end
          '';
        };
      };
    };

    lazygit = {
      enable = mkEnableOption "LazyGit integration";
      direction = mkOption {
        type = enum ["horizontal" "vertical" "tab" "float"];
        default = "float";
        description = "Direction of the lazygit window";
      };

      package = mkOption {
        type = nullOr package;
        default = pkgs.lazygit;
        description = "The package that should be used for lazygit. Setting it to null will attempt to use lazygit from your PATH";
      };

      mappings = {
        open = mkMappingOption config.vim.enableNvfKeymaps "Open lazygit [toggleterm]" "<leader>gg";
      };
    };
  };
}
