{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.binds) pushDownDefault;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.notes.obsidian;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [
        "obsidian-nvim"
        "vim-markdown"
        "tabular"
      ];

      binds.whichKey.register = pushDownDefault {
        "<leader>o" = "+Notes";
      };

      pluginRC.obsidian = entryAnywhere ''
        require("obsidian").setup(${toLuaObject cfg.setupOpts})
      '';

      # Don't set option unless we have a useful setting for it.
      notes.obsidian.setupOpts = let
        snacks = config.vim.utility.snacks-nvim.setupOpts.picker.enabled or false;
        mini = config.vim.mini.pick.enable;
        telescope = config.vim.telescope.enable;
        fzf-lua = config.vim.fzf-lua.enable;

        markdownExtensions = config.vim.languages.markdown.extensions;
        render-markdown = markdownExtensions.render-markdown-nvim.enable;
        markview = markdownExtensions.markview-nvim.enable;
      in
        mkMerge [
          (mkIf (snacks || mini || telescope || fzf-lua) {
            # plugin doesn't detect/choose this
            picker.name =
              if snacks
              then "snacks.pick"
              else if mini
              then "mini.pick"
              else if telescope
              then "telescope.nvim"
              else if fzf-lua
              then "fzf-lua"
              # NOTE: Shouldn't happen
              else null;
          })
          # Should be disabled automatically, but still causes issues in checkhealth.
          (mkIf (render-markdown || markview) {ui.enable = false;})
        ];

      # Resolve markdown image paths in the vault.
      # Only actually used by snacks if image.enabled is set to true
      utility.snacks-nvim.setupOpts = mkIf config.vim.utility.snacks-nvim.enable {
        image.resolve = mkLuaInline ''
          function(path, src)
            if require("obsidian.api").path_is_note(path) then
              return require("obsidian.api").resolve_image_path(src)
            end
          end
        '';
      };
    };
  };
}
