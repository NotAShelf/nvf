{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.modules) mkRenamedOptionModule mkRemovedOptionModule;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  imports = let
    renamedSetupOption = oldPath: newPath:
      mkRenamedOptionModule
      (["vim" "notes" "obsidian"] ++ oldPath)
      (["vim" "notes" "obsidian" "setupOpts"] ++ newPath);
  in [
    (
      mkRemovedOptionModule ["vim" "notes" "obsidian" "dir"]
      ''
        `obsidian.nvim` has migrated to the `setupOpts.workspaces` option to support multiple vaults with a single interface.

        To continue using a single vault, set:

        ```nix
        {
          notes.obsidian.setupOpts.workspaces = [
            {
              name = "any-string";
              path = "~/old/dir/path/value";
            }
          ];
        }
        ```
      ''
    )
    (renamedSetupOption ["daily-notes" "folder"] ["daily_notes" "folder"])
    (renamedSetupOption ["daily-notes" "date-format"] ["daily_notes" "date_format"])
    (renamedSetupOption ["completion"] ["completion"])
  ];
  options.vim.notes = {
    obsidian = {
      enable =
        mkEnableOption ""
        // {
          description = ''
            Whether to enable plugins to compliment the Obsidian markdown editor [obsidian.nvim].

            This plugin depends on [vim-markdown] which by default folds headings, including outside of workspaces/vaults.
            Set `vim.g['vim_markdown_folding_disable'] = 1` to disable automatic folding,
            or `vim.g['vim_markdown_folding_level'] = <number>` to set the default folding level.

            nvf will choose snacks.picker, mini.pick, telescope, or fzf-lua as the picker if they are enabled, in that order.

            The `ui` config module is automatically disabled if `render-markdown-nvim` or `markview-nvim` are enabled.
          '';
        };

      setupOpts = mkPluginSetupOption "obsidian.nvim" {};
    };
  };
}
