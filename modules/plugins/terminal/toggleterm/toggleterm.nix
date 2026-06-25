{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.types) nullOr enum package either int;
  inherit (lib.modules) mkRenamedOptionModule;
  inherit (lib.nvim.types) mkPluginSetupOption luaInline;
  inherit (lib.generators) mkLuaInline;
  inherit (config.vim.lib) mkMappingOption;
in {
  imports = [
    (mkRenamedOptionModule ["vim" "terminal" "toggleterm" "direction"] ["vim" "terminal" "toggleterm" "setupOpts" "direction"])
    (mkRenamedOptionModule ["vim" "terminal" "toggleterm" "enable_winbar"] ["vim" "terminal" "toggleterm" "setupOpts" "enable_winbar"])
  ];

  options.vim.terminal.toggleterm = {
    enable = mkEnableOption "toggleterm as a replacement to built-in terminal command";
    mappings = {
      open = mkMappingOption "Open toggleterm" "<c-t>";
    };

    setupOpts = mkPluginSetupOption "ToggleTerm" {
      direction = mkOption {
        type = enum ["horizontal" "vertical" "tab" "float"];
        default = "horizontal";
        description = "Direction of the terminal";
      };

      enable_winbar = mkEnableOption "winbar";

      size = mkOption {
        type = either luaInline int;
        default = mkLuaInline ''
          function(term)
            if term.direction == "horizontal" then
              return 15
            elseif term.direction == "vertical" then
              return vim.o.columns * 0.4
            end
          end
        '';
        defaultText = literalExpression ''
          mkLuaInline '''
            function(term)
              if term.direction == "horizontal" then
                return 15
              elseif term.direction == "vertical" then
                return vim.o.columns * 0.4
              end
            end
          '''
        '';
        description = "Integer or Lua function which is passed to the current terminal";
      };

      winbar = {
        enabled = mkEnableOption "winbar in terminal" // {default = true;};
        name_formatter = mkOption {
          type = luaInline;
          default = mkLuaInline ''
            function(term)
              return term.name
            end
          '';
          defaultText = literalExpression ''
            mkLuaInline '''
              function(term)
                return term.name
              end
            '''
          '';
          description = "Winbar formatter function.";
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
        defaultText = literalExpression "pkgs.lazygit";
        description = ''
          The package that should be used for lazygit.

          Setting this option to `null` will instead attempt to use `lazygit`
          from your {env}`PATH`
        '';
      };

      mappings = {
        open = mkMappingOption "Open lazygit [toggleterm]" "<leader>gg";
      };
    };
  };
}
