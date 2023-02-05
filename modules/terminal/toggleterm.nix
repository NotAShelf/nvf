{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.terminal.toggleterm;
in {
  options.vim.terminal.toggleterm = {
    enable = mkEnableOption "Enable toggleterm as a replacement to built-in terminal command";
    direction = mkOption {
      type = types.enum ["horizontal" "vertical" "tab" "float"];
      default = "float";
      description = "Direction of the terminal";
    };
    enable_winbar = mkOption {
      type = types.bool;
      default = false;
      description = "Enable winbar";
    };
  };

  config = mkIf cfg.enable {
    vim.startPlugins = [
      "toggleterm-nvim"
    ];

    vim.luaConfigRC.toggleterm = nvim.dag.entryAnywhere ''
      require("toggleterm").setup({
        open_mapping = [[<c-t>]],
        direction = '${toString cfg.direction}',
        -- TODO: this should probably be turned into a module that uses the lua function if and only if the user has not set it
        size = function(term)
          if term.direction == "horizontal" then
            return 15
          elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
          end
        end,
        winbar = {
          enabled = '${toString cfg.enable_winbar}',
          name_formatter = function(term) --  term: Terminal
            return term.name
          end
        },
      })
    '';
  };
}
