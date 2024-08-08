{
  lib,
  ...
}: let
  inherit (lib.options) mkOption;
  inherit (lib.types) attrsOf bool listOf str;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.utility.new-file-template = {
    enable = mkOption {
      type = bool;
      default = false;
      description = ''
        new-file-template.nvim: Automatically insert a template on new files in neovim.
        ::: {.note}
        For custom templates add a directory containing `lua/templates/*.lua`
        to `vim.additionalRuntimePaths`.
        :::
        [custom-template-docs]: https://github.com/otavioschwanck/new-file-template.nvim?tab=readme-ov-file#creating-new-templates
        More documentation on the templates available at [custom-template-docs]
      '';
    };

    setupOpts = mkPluginSetupOption "nvim-file-template.nvim" {
      disableInsert = mkOption {
        type = bool;
        default = false;
        description = "Enter insert mode after inserting the template";
      };

      disableAutocmd = mkOption {
        type = bool;
        default = false;
        description = "Disable the autocmd that creates the template";
      };

      disableFiletype = mkOption {
        type = listOf str;
        default = [];
        description = "Disable default templates for specific filetypes";
      };

      disableSpecific = mkOption {
        type = attrsOf (listOf str);
        default = {};
        description = "Disable specific regexp for the default templates.";
        example = "{ ruby = [\".*\"]; }";
      };

      suffixAsFiletype = mkOption {
        type = bool;
        default = false;
        description = "Use suffix of filename rather than `vim.bo.filetype` as filetype";
      };
    };
  };
}
