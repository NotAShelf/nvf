{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf nvim;
  inherit (nvim.vim) mkVimBool;

  cfg = config.vim.dashboard.startify;
in {
  config = mkIf cfg.enable {
    vim.startPlugins = with pkgs.vimPlugins; [vim-startify];

    vim.globals = {
      "startify_custom_header" =
        if cfg.customHeader == []
        then null
        else cfg.customHeader;
      "startify_custom_footer" =
        if cfg.customFooter == []
        then null
        else cfg.customFooter;
      "startify_bookmarks" = cfg.bookmarks;
      "startify_lists" = cfg.lists;
      "startify_change_to_dir" = mkVimBool cfg.changeToDir;
      "startify_change_to_vcs_root" = mkVimBool cfg.changeToVCRoot;
      "startify_change_cmd" = cfg.changeDirCmd;
      "startify_skiplist" = cfg.skipList;
      "startify_update_oldfiles" = mkVimBool cfg.updateOldFiles;
      "startify_session_autoload" = mkVimBool cfg.sessionAutoload;
      "startify_commands" = cfg.commands;
      "startify_files_number" = cfg.filesNumber;
      "startify_custom_indices" = cfg.customIndices;
      "startify_disable_at_vimenter" = mkVimBool cfg.disableOnStartup;
      "startify_enable_unsafe" = mkVimBool cfg.unsafe;
      "startify_padding_left" = cfg.paddingLeft;
      "startify_use_env" = mkVimBool cfg.useEnv;
      "startify_session_before_save" = cfg.sessionBeforeSave;
      "startify_session_persistence" = mkVimBool cfg.sessionPersistence;
      "startify_session_delete_buffers" = mkVimBool cfg.sessionDeleteBuffers;
      "startify_session_dir" = cfg.sessionDir;
      "startify_skiplist_server" = cfg.skipListServer;
      "startify_session_remove_lines" = cfg.sessionRemoveLines;
      "startify_session_savevars" = cfg.sessionSavevars;
      "startify_session_savecmds" = cfg.sessionSavecmds;
      "startify_session_sort" = mkVimBool cfg.sessionSort;
    };
  };
}
