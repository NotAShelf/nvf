{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.treesitter.textobjects = {
    enable = mkEnableOption ''
      Treesitter textobjects. You'll have to add your own {option}`vim.keymaps`.

      Example:
      ```nix
      vim.keymaps = [
        {
          mode = ["o" "x"];
          key = "af";
          lua = true;
          action = '''
            require("nvim-treesitter-textobjects.select").select_textobject(
              "@function.outer", "textobjects"
            )
          ''';
        }
      ];
      ```
    '';
    setupOpts =
      mkPluginSetupOption "treesitter-textobjects" {}
      // {
        example = {
          select = {
            lookahead = true;
            selection_modes = {
              "@parameter.outer" = "v";
              "@function.outer" = "V";
              "@class.outer" = "<c-v>";
            };
          };
        };
      };
  };
}
