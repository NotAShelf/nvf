{
  lib,
  config,
  ...
}: let
  inherit (builtins) concatStringsSep;
  inherit (lib) optionalString mkIf nvim;

  cfg = config.vim;
in {
  config = {
    vim.startPlugins = ["plenary-nvim"] ++ lib.optionals (cfg.spellChecking.enableProgrammingWordList) ["vim-dirtytalk"];

    vim.maps.normal =
      mkIf cfg.disableArrows {
        "<up>" = {
          action = "<nop>";

          noremap = false;
        };
        "<down>" = {
          action = "<nop>";

          noremap = false;
        };
        "<left>" = {
          action = "<nop>";
          noremap = false;
        };
        "<right>" = {
          action = "<nop>";
          noremap = false;
        };
      }
      // mkIf cfg.mapLeaderSpace {
        "<space>" = {
          action = "<nop>";
        };
      };

    vim.maps.insert = mkIf cfg.disableArrows {
      "<up>" = {
        action = "<nop>";
        noremap = false;
      };
      "<down>" = {
        action = "<nop>";
        noremap = false;
      };
      "<left>" = {
        action = "<nop>";
        noremap = false;
      };
      "<right>" = {
        action = "<nop>";
        noremap = false;
      };
    };

    vim.configRC.basic = nvim.dag.entryAfter ["globalsScript"] ''
      ${optionalString cfg.debugMode.enable ''
        " Debug mode settings
        set verbose=${toString cfg.debugMode.level}
        set verbosefile=${cfg.debugMode.logFile}
      ''}

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
      ${optionalString cfg.spellChecking.enable ''
        set spell
        set spelllang=${concatStringsSep "," cfg.spellChecking.languages}${optionalString cfg.spellChecking.enableProgrammingWordList ",programming"}
      ''}
      ${optionalString (cfg.leaderKey != null) ''
        let mapleader = "${toString cfg.leaderKey}"
      ''}
      ${optionalString (cfg.searchCase == "ignore") ''
        set nosmartcase
        set ignorecase
      ''}
      ${optionalString (cfg.searchCase == "smart") ''
        set noignorecase
        set smartcase
      ''}
      ${optionalString (cfg.searchCase == "sensitive") ''
        set noignorecase
        set nosmartcase
      ''}
    '';
  };
}
