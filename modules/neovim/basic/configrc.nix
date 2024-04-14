{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption literalExpression;
  inherit (lib.strings) optionalString;
  inherit (lib.types) enum bool str int nullOr;
  inherit (lib.nvim.dag) entryAfter;

  cfg = config.vim;
in {
  options.vim = {
    leaderKey = mkOption {
      type = nullOr str;
      default = null;
      description = "The leader key to be used internally";
    };

    colourTerm = mkOption {
      type = bool;
      default = true;
      description = "Set terminal up for 256 colours";
    };

    disableArrows = mkOption {
      type = bool;
      default = false;
      description = "Set to prevent arrow keys from moving cursor";
    };

    hideSearchHighlight = mkOption {
      type = bool;
      default = false;
      description = "Hide search highlight so it doesn't stay highlighted";
    };

    scrollOffset = mkOption {
      type = int;
      default = 8;
      description = "Start scrolling this number of lines from the top or bottom of the page.";
    };

    wordWrap = mkOption {
      type = bool;
      default = true;
      description = "Enable word wrapping.";
    };

    syntaxHighlighting = mkOption {
      type = bool;
      default = true;
      description = "Enable syntax highlighting";
    };

    mapLeaderSpace = mkOption {
      type = bool;
      default = true;
      description = "Map the space key to leader key";
    };

    useSystemClipboard = mkOption {
      type = bool;
      default = false;
      description = "Make use of the clipboard for default yank and paste operations. Don't use * and +";
    };

    mouseSupport = mkOption {
      type = enum ["a" "n" "v" "i" "c"];
      default = "a";
      description = ''
        Set modes for mouse support.

        * a - all
        * n - normal
        * v - visual
        * i - insert
        * c - command
      '';
    };

    lineNumberMode = mkOption {
      type = enum ["relative" "number" "relNumber" "none"];
      default = "relNumber";
      example = literalExpression "none";
      description = "How line numbers are displayed.";
    };

    preventJunkFiles = mkOption {
      type = bool;
      default = false;
      description = "Prevent swapfile and backupfile from being created";
    };

    tabWidth = mkOption {
      type = int;
      default = 4;
      description = "Set the width of tabs";
    };

    autoIndent = mkOption {
      type = bool;
      default = true;
      description = "Enable auto indent";
    };

    cmdHeight = mkOption {
      type = int;
      default = 1;
      description = "Height of the command pane";
    };

    updateTime = mkOption {
      type = int;
      default = 300;
      description = "The number of milliseconds till Cursor Hold event is fired";
    };

    showSignColumn = mkOption {
      type = bool;
      default = true;
      description = "Show the sign column";
    };

    bell = mkOption {
      type = enum ["none" "visual" "on"];
      default = "none";
      description = "Set how bells are handled. Options: on, visual or none";
    };

    mapTimeout = mkOption {
      type = int;
      default = 500;
      description = "Timeout in ms that neovim will wait for mapped action to complete";
    };

    splitBelow = mkOption {
      type = bool;
      default = true;
      description = "New splits will open below instead of on top";
    };

    splitRight = mkOption {
      type = bool;
      default = true;
      description = "New splits will open to the right";
    };
    enableEditorconfig = mkOption {
      type = bool;
      default = true;
      description = "Follow editorconfig rules in current directory";
    };

    cursorlineOpt = mkOption {
      type = enum ["line" "screenline" "number" "both"];
      default = "line";
      description = "Highlight the text line of the cursor with CursorLine hl-CursorLine";
    };

    searchCase = mkOption {
      type = enum ["ignore" "smart" "sensitive"];
      default = "sensitive";
      description = "Set the case sensitivity of search";
    };
  };

  config.vim.configRC.basic = entryAfter ["globalsScript"] ''
    " Settings that are set for everything
    set encoding=utf-8
    set mouse=${cfg.mouseSupport}
    set tabstop=${toString cfg.tabWidth}
    set shiftwidth=${toString cfg.tabWidth}
    set softtabstop=${toString cfg.tabWidth}
    set expandtab
    set cmdheight=${toString cfg.cmdHeight}
    set updatetime=${toString cfg.updateTime}
    set shortmess+=c
    set tm=${toString cfg.mapTimeout}
    set hidden
    set cursorlineopt=${toString cfg.cursorlineOpt}
    set scrolloff=${toString cfg.scrollOffset}

    ${optionalString cfg.debugMode.enable ''
      " Debug mode settings
      set verbose=${toString cfg.debugMode.level}
      set verbosefile=${cfg.debugMode.logFile}
    ''}

    ${optionalString cfg.splitBelow ''
      set splitbelow
    ''}

    ${optionalString cfg.splitRight ''
      set splitright
    ''}

    ${optionalString cfg.showSignColumn ''
      set signcolumn=yes
    ''}

    ${optionalString cfg.autoIndent ''
      set autoindent
    ''}

    ${optionalString cfg.preventJunkFiles ''
      set noswapfile
      set nobackup
      set nowritebackup
    ''}

    ${optionalString (cfg.bell == "none") ''
      set noerrorbells
      set novisualbell
    ''}

    ${optionalString (cfg.bell == "on") ''
      set novisualbell
    ''}

    ${optionalString (cfg.bell == "visual") ''
      set noerrorbells
    ''}

    ${optionalString (cfg.lineNumberMode == "relative") ''
      set relativenumber
    ''}

    ${optionalString (cfg.lineNumberMode == "number") ''
      set number
    ''}

    ${optionalString (cfg.lineNumberMode == "relNumber") ''
      set number relativenumber
    ''}

    ${optionalString cfg.useSystemClipboard ''
      set clipboard+=unnamedplus
    ''}

    ${optionalString cfg.mapLeaderSpace ''
      let mapleader=" "
      let maplocalleader=" "
    ''}

    ${optionalString cfg.syntaxHighlighting ''
      syntax on
    ''}

    ${optionalString (!cfg.wordWrap) ''
      set nowrap
    ''}

    ${optionalString cfg.hideSearchHighlight ''
      set nohlsearch
      set incsearch
    ''}

    ${optionalString cfg.colourTerm ''
      set termguicolors
      set t_Co=256
    ''}

    ${optionalString (!cfg.enableEditorconfig) ''
      let g:editorconfig = v:false
    ''}

    ${optionalString (cfg.leaderKey != null) ''
      let mapleader = "${toString cfg.leaderKey}"
    ''}

    ${optionalString (cfg.searchCase == "ignore") ''
      set nosmartcase
      set ignorecase
    ''}

    ${optionalString (cfg.searchCase == "smart") ''
      set smartcase
      set ignorecase
    ''}

    ${optionalString (cfg.searchCase == "sensitive") ''
      set nosmartcase
      set noignorecase
    ''}
  '';
}
