{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption;

  inherit (lib.types) enum listOf str nullOr int;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.utility.images.image-nvim = {
    enable = mkEnableOption "image support in Neovim [image.nvim]";

    setupOpts = mkPluginSetupOption "image.nvim" {
      backend = mkOption {
        type = enum ["kitty" "ueberzug" "sixel"];
        default = "ueberzug";
        description = ''
          The backend to use for rendering images.

          * `kitty` - best in class, works great and is very snappy. Recommended
          by upstream.
          * `ueberzug` - backed by ueberzugpp, supports any terminal,
            but has lower performance
          * `sixel` - uses the Sixel graphics protocol, widely supported by many terminals
        '';
      };

      integrations = {
        markdown = {
          enable = mkEnableOption " image.nvim in markdown files" // {default = true;};
          clearInInsertMode = mkEnableOption "clearing of images when entering insert mode";
          downloadRemoteImages = mkEnableOption "downloading remote images";
          onlyRenderAtCursor = mkEnableOption "only rendering images at cursor";
          filetypes = mkOption {
            type = listOf str;
            default = ["markdown" "vimwiki"];
            description = ''
              Filetypes to enable image.nvim in. Markdown extensions
              (i.e. quarto) can go here
            '';
          };
        };

        neorg = {
          enable = mkEnableOption "image.nvim in Neorg files" // {default = true;};
          clearInInsertMode = mkEnableOption "clearing of images when entering insert mode";
          downloadRemoteImages = mkEnableOption "downloading remote images";
          onlyRenderAtCursor = mkEnableOption "only rendering images at cursor";
          filetypes = mkOption {
            type = listOf str;
            default = ["neorg"];
            description = ''
              Filetypes to enable image.nvim in.
            '';
          };
        };

        maxWidth = mkOption {
          type = nullOr int;
          default = null;
          description = ''
            The maximum width of images to render. Images larger than
            this will be scaled down to fit within this width.
          '';
        };
      };

      maxHeight = mkOption {
        type = nullOr int;
        default = null;
        description = ''
          The maximum height of images to render. Images larger than
          this will be scaled down to fit within this height.
        '';
      };

      maxWidthWindowPercentage = mkOption {
        type = nullOr int;
        default = null;
        description = ''
          The maximum width of images to render as a percentage of the
          window width. Images larger than this will be scaled down to
          fit within this width.
        '';
      };

      maxHeightWindowPercentage = mkOption {
        type = nullOr int;
        default = 50;
        description = ''
          The maximum height of images to render as a percentage of the
          window height. Images larger than this will be scaled down to
          fit within this height.
        '';
      };

      windowOverlapClear = {
        enable = mkEnableOption "clearing of images when they overlap with the window";
        ftIgnore = mkOption {
          type = listOf str;
          default = ["cmp_menu" "cmp_docs" ""];
          description = ''
            Filetypes to ignore window overlap clearing in.
          '';
        };
      };

      editorOnlyRenderWhenFocused = mkEnableOption "only rendering images when the editor is focused";
      hijackFilePatterns = mkOption {
        type = listOf str;
        default = ["*.png" "*.jpg" "*.jpeg" "*.gif" "*.webp"];
        description = ''
          File patterns to hijack for image.nvim. This is useful for
          filetypes that don't have a dedicated integration.
        '';
      };
    };
  };
}
