{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption literalExpression literalMD;
  inherit (lib.strings) optionalString;
  inherit (lib.types) enum bool str int either;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.dag) entryAfter;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.types) luaInline;

  cfg = config.vim;
in {
  options.vim = {
    leaderKey = mkOption {
      type = str;
      default = " ";
      description = "The leader key used for `<leader>` mappings";
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
      default = !config.vim.treesitter.highlight.enable;
      description = "Enable syntax highlighting";
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

    undoFile = {
      enable = mkEnableOption "undofile for persistent undo behaviour";
      path = mkOption {
        type = either str luaInline;
        default = mkLuaInline "vim.fn.stdpath('state') .. '/undo'";
        defaultText = literalMD ''
          ```nix
          mkLuaInline "vim.fn.stdpath('state') .. '/undo'"
          ```
        '';
        example = literalMD ''
          ```nix
          mkLuaInline "os.getenv('XDG_DATA_HOME') .. '/nvf/undo'"
          ```
        '';
        description = "Path to the directory in which undo history will be stored";
      };
    };
  };

  config = {
    vim.luaConfigRC.basic = entryAfter ["globalsScript"] ''
      -- Settings that are set for everything
      vim.o.encoding = "utf-8"
      vim.o.hidden = true
      vim.opt.shortmess:append("c")
      vim.o.expandtab = true
      vim.o.mouse = ${toLuaObject cfg.mouseSupport}
      vim.o.tabstop = ${toLuaObject cfg.tabWidth}
      vim.o.shiftwidth = ${toLuaObject cfg.tabWidth}
      vim.o.softtabstop = ${toLuaObject cfg.tabWidth}
      vim.o.cmdheight = ${toLuaObject cfg.cmdHeight}
      vim.o.updatetime = ${toLuaObject cfg.updateTime}
      vim.o.tm = ${toLuaObject cfg.mapTimeout}
      vim.o.cursorlineopt = ${toLuaObject cfg.cursorlineOpt}
      vim.o.scrolloff = ${toLuaObject cfg.scrollOffset}
      vim.g.mapleader = ${toLuaObject cfg.leaderKey}
      vim.g.maplocalleader = ${toLuaObject cfg.leaderKey}

      ${optionalString cfg.undoFile.enable ''
        vim.o.undofile = true
        vim.o.undodir = ${toLuaObject cfg.undoFile.path}
      ''}

      ${optionalString cfg.splitBelow ''
        vim.o.splitbelow = true
      ''}

      ${optionalString cfg.splitRight ''
        vim.o.splitright = true
      ''}

      ${optionalString cfg.showSignColumn ''
        vim.o.signcolumn = "yes"
      ''}

      ${optionalString cfg.autoIndent ''
        vim.o.autoindent = true
      ''}

      ${optionalString cfg.preventJunkFiles ''
        vim.o.swapfile = false
        vim.o.backup = false
        vim.o.writebackup = false
      ''}

      ${optionalString (cfg.bell == "none") ''
        vim.o.errorbells = false
        vim.o.visualbell = false
      ''}

      ${optionalString (cfg.bell == "on") ''
        vim.o.visualbell = false
      ''}

      ${optionalString (cfg.bell == "visual") ''
        vim.o.errorbells = false
      ''}

      ${optionalString (cfg.lineNumberMode == "relative") ''
        vim.o.relativenumber = true
      ''}

      ${optionalString (cfg.lineNumberMode == "number") ''
        vim.o.number = true
      ''}

      ${optionalString (cfg.lineNumberMode == "relNumber") ''
        vim.o.number = true
        vim.o.relativenumber = true
      ''}

      ${optionalString cfg.useSystemClipboard ''
        vim.opt.clipboard:append("unnamedplus")
      ''}

      ${optionalString cfg.syntaxHighlighting ''
        vim.cmd("syntax on")
      ''}

      ${optionalString (!cfg.wordWrap) ''
        vim.o.wrap = false
      ''}

      ${optionalString cfg.hideSearchHighlight ''
        vim.o.hlsearch = false
        vim.o.incsearch = true
      ''}

      ${optionalString cfg.colourTerm ''
        vim.o.termguicolors = true
      ''}

      ${optionalString (!cfg.enableEditorconfig) ''
        vim.g.editorconfig = false
      ''}

      ${optionalString (cfg.searchCase == "ignore") ''
        vim.o.smartcase = false
        vim.o.ignorecase = true
      ''}

      ${optionalString (cfg.searchCase == "smart") ''
        vim.o.smartcase = true
        vim.o.ignorecase = true
      ''}

      ${optionalString (cfg.searchCase == "sensitive") ''
        vim.o.smartcase = false
        vim.o.ignorecase = false
      ''}
    '';
  };
}
