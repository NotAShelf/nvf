{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;

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
      "startify_change_to_dir" = cfg.changeToDir;
      "startify_change_to_vcs_root" = cfg.changeToVCRoot;
      "startify_change_cmd" = cfg.changeDirCmd;
      "startify_skiplist" = cfg.skipList;
      "startify_update_oldfiles" = cfg.updateOldFiles;
      "startify_session_autoload" = cfg.sessionAutoload;
      "startify_commands" = cfg.commands;
      "startify_files_number" = cfg.filesNumber;
      "startify_custom_indices" = cfg.customIndices;
      "startify_disable_at_vimenter" = cfg.disableOnStartup;
      "startify_enable_unsafe" = cfg.unsafe;
      "startify_padding_left" = cfg.paddingLeft;
      "startify_use_env" = cfg.useEnv;
      "startify_session_before_save" = cfg.sessionBeforeSave;
      "startify_session_persistence" = cfg.sessionPersistence;
      "startify_session_delete_buffers" = cfg.sessionDeleteBuffers;
      "startify_session_dir" = cfg.sessionDir;
      "startify_skiplist_server" = cfg.skipListServer;
      "startify_session_remove_lines" = cfg.sessionRemoveLines;
      "startify_session_savevars" = cfg.sessionSavevars;
      "startify_session_savecmds" = cfg.sessionSavecmds;
      "startify_session_sort" = cfg.sessionSort;
    };
  };
}
