{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption literalMD;
  inherit (lib.nvim.binds) mkMappingOption;
  inherit (lib.types) listOf package str either;
  inherit (lib.nvim.types) luaInline;

  inherit (pkgs.vimPlugins.nvim-treesitter) builtGrammars;
in {
  options.vim.treesitter = {
    enable = mkEnableOption "treesitter, also enabled automatically through language options";

    mappings.incrementalSelection = {
      init = mkMappingOption "Init selection [treesitter]" "gnn";
      incrementByNode = mkMappingOption "Increment selection by node [treesitter]" "grn";
      incrementByScope = mkMappingOption "Increment selection by scope [treesitter]" "grc";
      decrementByNode = mkMappingOption "Decrement selection by node [treesitter]" "grm";
    };

    fold = mkEnableOption "fold with treesitter";
    autotagHtml = mkEnableOption "autoclose and rename html tag";
    grammars = mkOption {
      type = listOf package;
      default = [];
      description = ''
        List of treesitter grammars to install.

        For languages already supported by neovim-flake, you may
        use the {option}`vim.language.<lang>.treesitter` options, which
        will automatically add the required grammars to this.
      '';
    };

    highlight = {
      enable = mkEnableOption "highlighting with treesitter";
      disable = mkOption {
        type = either (luaInline (listOf str));
        default = [];
        example = literalMD ''
          ```lua
          -- Disable slow treesitter highlight for large files
          disable = function(lang, buf)
            local max_filesize = 1000 * 1024 -- 1MB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
                return true
            end
          end
          ```
        '';

        description = ''
          List of treesitter grammars to disable highlighting for.

          This option can be either a list, in which case it will be
          converted to a Lua table containing grammars to disable
          highlighting for, or a string containing a **lua function**
          that will be read as is.

          ::: {.warning}
          A comma will be added at the end of your function, so you
          do not need to add it yourself. Doing so will cause in
          syntax errors within your Neovim configuration.
          :::
        '';
      };
    };

    defaultGrammars = mkOption {
      internal = true;
      readOnly = true;
      type = listOf package;
      default = with builtGrammars; [c lua vim vimdoc query];
      description = ''
        A list of treesitter grammars that will be installed by default
        if treesitter has been enabled.

        ::: {.warning}
        Regardless of which language module options you enable, Neovim
        depends on those grammars to be enabled while treesitter is enabled.
        This list cannot be modified, but its contents will only be appended
        if the list of grammars does not contain the required grammars.
        :::
      '';
    };
  };
}
