{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkRenamedOptionModule;
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.types) listOf str;
  inherit (lib.nvim.lua) listToLuaTable;
  inherit (lib.nvim.dag) entryAfter;

  cfg = config.vim.spellcheck;
in {
  imports = [
    (mkRenamedOptionModule ["vim" "spellChecking"] ["vim" "spellcheck"])
  ];

  options.vim.spellcheck = {
    enable = mkEnableOption "Neovim's built-in spellchecking";
    languages = mkOption {
      type = listOf str;
      default = ["en"];
      example = literalExpression ''["en" "de"]'';
      description = ''
        A list of languages that should be used for spellchecking.

        To add your own language files, you may place your `spell`
        directory in either `~/.config/nvim` or the
        [additionalRuntimePaths](#opt-vim.additionalRuntimePaths)
        directory provided by **nvf**.
      '';
    };

    ignoredFiletypes = mkOption {
      type = listOf str;
      default = ["toggleterm"];
      example = literalExpression ''["markdown" "gitcommit"]'';
      description = ''
        A list of filetypes for which spellchecking will be disabled.

        You may use `echo &filetype` in Neovim to find out the
        filetype for a specific buffer.
      '';
    };

    /*
    # FIXME: This needs to be revisited. It tries to install
    # the spellfile to an user directory, but it cannot do so
    # as we sanitize runtime paths.
    programmingWordlist.enable = mkEnableOption ''
      vim-dirtytalk, a wordlist for programmers containing
      common programming terms.

      Setting this value as `true` has the same effect
      as setting {option}`vim.spellCheck.enable`
    '';
    */
  };

  config = mkIf cfg.enable {
    vim.luaConfigRC.spellcheck = entryAfter ["basic"] ''
      vim.opt.spell = true
      vim.opt.spelllang = ${listToLuaTable cfg.languages}

      -- Disable spellchecking for certain filetypes
      -- as configured by `vim.spellcheck.ignoredFiletypes`
      vim.api.nvim_create_autocmd({ "FileType" }, {
        pattern = ${listToLuaTable cfg.ignoredFiletypes},
        callback = function()
          vim.opt_local.spell = false
        end,
      })
    '';
  };
}
