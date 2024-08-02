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
      description = "new-file-template.nvim: Automatically insert a template on new files in neovim";
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
        description = "Disable templates for specific filetypes (only disables default templates, user templates will still work)";
      };

      disableSpecific = mkOption {
        type = attrsOf (listOf str);
        default = {};
        description = "Disable specific regexp for the default templates. Example: { ruby = [ \".*\" ]; }";
        example = {
          ruby = [".*"];
        };
      };

      suffixAsFiletype = mkOption {
        type = bool;
        default = false;
        description = "Use suffix of filename rather than vim.bo.filetype as filetype";
      };
    };
  };
}
