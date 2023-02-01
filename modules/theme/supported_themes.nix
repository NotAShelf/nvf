{
  onedark = {
    setup = { style ? "dark" }: ''
      -- OneDark theme
      require('onedark').setup {
        style = "${style}"
      }
      require('onedark').load()
    '';
    styles = [ "dark" "darker" "cool" "deep" "warm" "warmer" ];
  };

  tokyonight = {
    setup = { style ? "night" }: ''
      -- need to set style before colorscheme to apply
      vim.g.tokyonight_style = '${style}'
      vim.cmd[[colorscheme tokyonight]]
    '';
    styles = [ "day" "night" "storm" ];
  };

  catppuccin = {
    setup = { style ? "mocha" }: ''
      -- Catppuccin theme
      require('catppuccin').setup {
        flavour = "${style}"
      }
      -- setup must be called before loading
      vim.cmd.colorscheme "catppuccin"
    '';
    styles = [ "latte" "frappe" "macchiato" "mocha" ];
  };
}
