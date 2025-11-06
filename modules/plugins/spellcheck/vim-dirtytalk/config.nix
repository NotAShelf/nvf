{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAfter;
  cfg = config.vim.spellcheck;
in {
  config = mkIf cfg.programmingWordlist.enable {
    vim = {
      startPlugins = ["vim-dirtytalk"];

      spellcheck.enable = true;

      # vim-dirtytalk doesn't have any setup but we would
      # like to append programming to spelllangs as soon as
      # possible while the plugin is enabled and the state
      # directory can be found.
      luaConfigRC.vim-dirtytalk = entryAfter ["spellcheck"] ''
        -- If Neovim can find (or access) the state directory
        -- then append "programming" wordlist from vim-dirtytalk
        -- to spelllang table. If path cannot be found, display
        -- an error and avoid appending the programming words
        if vim.fn.isdirectory(vim.fn.stdpath('state')) == 1 then
          vim.opt.spelllang:append("programming")
        else
          vim.notify("State path does not exist: " .. state_path, vim.log.levels.ERROR)
        end
      '';
    };
  };
}
