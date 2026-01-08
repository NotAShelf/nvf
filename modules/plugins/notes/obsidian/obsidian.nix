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

        See the [wiki](https://github.com/obsidian-nvim/obsidian.nvim/wiki/Workspace#vault-based-workspaces) for more information.
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
            Whether to enable plugins to complement the Obsidian markdown editor [obsidian.nvim].

            Enables [vim-markdown] which automatically folds markdown headings inside and outside of workspaces/vaults.
            Set {option}`vim.globals.vim_markdown_folding_disable = 1;` to disable automatic folding,
            or {option}`vim.globals.vim_markdown_folding_level = <heading-level-int>;` to set the default fold level for new buffers.

            nvf will choose one of `snacks.picker`, `mini.pick`, `telescope`, or `fzf-lua` as the `obsidian.nvim` picker based on whether they are enabled, in that order.

            You can enable one of them with one of the following:

            - {option}`vim.utility.snacks-nvim.setupOpts.picker.enabled` and {option}`vim.utility.snacks-nvim.enable`
            - {option}`vim.mini.pick.enable`
            - {option}`vim.telescope.enable`
            - {option}`vim.fzf-lua.enable`

            {option}`vim.notes.obsidian.setupOpts.ui.enable` is automatically disabled if `render-markdown.nvim` or `markview.nvim` are enabled.

            [vim-markdown]: https://github.com/preservim/vim-markdown?tab=readme-ov-file#options
          '';
        };

      setupOpts = mkPluginSetupOption "obsidian.nvim" {};
    };
  };
}
