{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption;

  inherit (lib.types) enum listOf str;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.utility.images.image-nvim = {
    enable = mkEnableOption ''
      image support in Neovim [image.nvim].
      See <https://github.com/3rd/image.nvim#default-configuration> for all configuration options.
    '';

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
      processor = mkOption {
        type = enum ["magick_cli" "magick_rock"];
        default = "magick_rock";
        description = "The processor to use for image magick.";
      };

      hijack_file_patterns = mkOption {
        type = listOf str;
        default = ["*.png" "*.jpg" "*.jpeg" "*.gif" "*.webp" "*.svg"];
        description = ''
          File patterns to hijack for image.nvim. This is useful for
          filetypes that don't have a dedicated integration.
        '';
      };
    };
  };
}
