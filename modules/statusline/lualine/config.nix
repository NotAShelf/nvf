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
        left = mkDefault "";
        right = mkDefault "";
      };

      activeSection = {
        # left side of the statusline 4
        a = mkDefault "{'mode'}";
        b = mkDefault ''
          {
            {
              "filename",
              color = {bg='none'},
              symbols = {modified = '', readonly = ''},
            },
          }
        '';
        c = mkDefault ''
          {
            {
              "branch",
              icon = ' •',
              separator = { left = '(', right = ')'},
            },
          }
        '';
        # right side of the statusline (x, y, z)
        x = mkDefault ''
          {
            {
              "diagnostics",
              sources = {'nvim_lsp', 'nvim_diagnostic'},
              symbols = {error = '', warn = '', info = '', hint = ''}
            },
          }
        '';
        y = mkDefault ''
          {
            {
              "fileformat",
              color = {bg='none'}
            },
          }
        '';
        z = mkDefault ''
          {
            {
              "progress",
              color = {
                bg='none',
                fg='lavender'
              }
            },
            {
              "location",
              color = {bg='none', fg='lavender'},
            },
            {
              "filetype",
              color = {bg='none', fg='lavender'},
            },
          }
        '';
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
