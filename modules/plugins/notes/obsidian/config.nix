{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.dag) entryAnywhere;
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

      pluginRC.obsidian = entryAnywhere ''
        require("obsidian").setup(${toLuaObject cfg.setupOpts})
      '';

      notes.obsidian.setupOpts = let
        # may not be defined
        snacks-picker.enable = config.vim.utility.snacks-nvim.setupOpts.picker.enabled or false;
        mini-pick = config.vim.mini.pick;
        inherit (config.vim) telescope fzf-lua;

        inherit (config.vim.languages.markdown.extensions) render-markdown-nvim markview-nvim;
      in
        mkMerge [
          # Don't set option unless we have a useful setting for it.
          (mkIf (snacks-picker.enable || mini-pick.enable || telescope.enable || fzf-lua.enable) {
            # It doesn't detect/choose this.
            # Some pickers and completion plugins don't get detected correctly by the checkhealth, but they all work.
            # Values taken from the [config's](https://github.com/obsidian-nvim/obsidian.nvim/blob/main/lua/obsidian/config/init.lua) valid ones.
            picker.name =
              if snacks-picker.enable
              then "snacks.pick"
              else if mini-pick.enable
              then "mini.pick"
              else if telescope.enable
              then "telescope.nvim"
              else if fzf-lua.enable
              then "fzf-lua"
              # NOTE: Shouldn't happen with the if-guard.
              else null;
          })

          # Should be disabled automatically, but still shows up in render-markdown's checkhealth.
          # This is also useful in that it will conflict with a user explicitly enabling it
          # without mkForce, which is probably a copy paste issue and a sign to look at
          # whether this option is useful.
          (mkIf (render-markdown-nvim.enable || markview-nvim.enable) {ui.enable = false;})
        ];

      # Resolve markdown image paths in the vault.
      # Only actually used by snacks if image.enabled is set to true and
      # required programs are supplied and `attachments.img_folder` is correct.
      # From https://github.com/obsidian-nvim/obsidian.nvim/wiki/Images,
      # which notes the API might change.
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
