{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption literalMD;
  inherit (lib.strings) optionalString;
  inherit (lib.attrsets) optionalAttrs;
  inherit (lib.types) enum bool str either;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.dag) entryAfter;
  inherit (lib.nvim.binds) pushDownDefault;
  inherit (lib.nvim.types) luaInline;

  cfg = config.vim;
in {
  options.vim = {
    hideSearchHighlight = mkOption {
      type = bool;
      default = false;
      description = "Hide search highlight so it doesn't stay highlighted";
    };

    syntaxHighlighting = mkOption {
      type = bool;
      default = !config.vim.treesitter.highlight.enable;
      description = "Enable syntax highlighting";
    };

    lineNumberMode = mkOption {
      type = enum ["relative" "number" "relNumber" "none"];
      default = "relNumber";
      example = "none";
      description = "How line numbers are displayed.";
    };

    preventJunkFiles = mkOption {
      type = bool;
      default = true;
      example = false;
      description = ''
        Prevent swapfile and backupfile from being created.

        `false` is the default Neovim behaviour. If you wish to create
        backup and swapfiles, set this option to `false`.
      '';
    };

    bell = mkOption {
      type = enum ["none" "visual" "on"];
      default = "none";
      description = "Set how bells are handled. Options: on, visual or none";
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

  config.vim = {
    # Set options that were previously interpolated in 'luaConfigRC.basic' as vim.options (vim.o)
    # and 'vim.globals' (vim.g). Future options, if possible, should be added here instead of the
    # luaConfigRC section below.
    options = pushDownDefault (lib.mergeAttrsList [
      {
        # Options that are always set, with a lower priority
        encoding = "utf-8";
        hidden = true;
        expandtab = true;

        # Junkfile Behaviour
        swapfile = !cfg.preventJunkFiles;
        backup = !cfg.preventJunkFiles;
        writebackup = !cfg.preventJunkFiles;
      }

      (optionalAttrs cfg.undoFile.enable {
        undofile = true;
        undodir = cfg.undoFile.path;
      })

      (optionalAttrs (cfg.bell == "none") {
        errorbells = false;
        visualbell = false;
      })

      (optionalAttrs (cfg.bell == "on") {
        visualbell = false;
      })

      (optionalAttrs (cfg.bell == "visual") {
        visualbell = false;
      })

      (optionalAttrs (cfg.lineNumberMode == "relative") {
        relativenumber = true;
      })

      (optionalAttrs (cfg.lineNumberMode == "number") {
        number = true;
      })

      (optionalAttrs (cfg.lineNumberMode == "relNumber") {
        number = true;
        relativenumber = true;
      })
    ]);

    # Options that are more difficult to set through 'vim.options'. Namely, appending values
    # to pre-set Neovim options. Fear not, though as the Lua DAG is still as powerful as it
    # could be.
    luaConfigRC.basic = entryAfter ["globalsScript"] ''
      ${optionalString cfg.syntaxHighlighting ''
        vim.cmd("syntax on")
      ''}

      ${optionalString cfg.hideSearchHighlight ''
        vim.o.hlsearch = false
        vim.o.incsearch = true
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
