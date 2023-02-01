{
  pkgs,
  config,
  lib,
  ...
}:
with lib; {
  config = {
    vim.statusline.lualine = {
      enable = mkDefault false;

      icons = mkDefault true;
      theme = mkDefault "auto";
      sectionSeparator = {
        left = mkDefault "";
        right = mkDefault "";
      };

      componentSeparator = {
        left = mkDefault "⏽";
        right = mkDefault "⏽";
      };

      activeSection = {
        a = mkDefault "{'mode'}";
        b = ''
          {
            {
              "branch",
              separator = '',
            },
            "diff",
          }
        '';
        c = mkDefault "{'filename'}";
        x = mkDefault ''
          {
            {
              "diagnostics",
              sources = {'nvim_lsp'},
              separator = '',
              symbols = {error = '', warn = '', info = '', hint = ''},
            },
            {
              "filetype",
            },
            "fileformat",
            "encoding",
          }
        '';
        y = mkDefault "{'progress'}";
        z = mkDefault "{'location'}";
      };

      inactiveSection = {
        a = mkDefault "{}";
        b = mkDefault "{}";
        c = mkDefault "{'filename'}";
        x = mkDefault "{'location'}";
        y = mkDefault "{}";
        z = mkDefault "{}";
      };
    };
  };
}
