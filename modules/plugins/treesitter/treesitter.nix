{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption literalMD literalExpression;
  inherit (lib.types) listOf package str either bool;
  inherit (lib.nvim.binds) mkMappingOption;
  inherit (lib.nvim.types) luaInline;
in {
  options.vim.treesitter = {
    enable = mkEnableOption "treesitter, also enabled automatically through language options";

    mappings.incrementalSelection = {
      init = mkMappingOption config.vim.enableNvfKeymaps "Init selection [treesitter]" "gnn";
      incrementByNode = mkMappingOption config.vim.enableNvfKeymaps "Increment selection by node [treesitter]" "grn";
      incrementByScope = mkMappingOption config.vim.enableNvfKeymaps "Increment selection by scope [treesitter]" "grc";
      decrementByNode = mkMappingOption config.vim.enableNvfKeymaps "Decrement selection by node [treesitter]" "grm";
    };

    fold = mkEnableOption "fold with treesitter";
    autotagHtml = mkEnableOption "autoclose and rename html tag";

    grammars = mkOption {
      type = listOf package;
      default = [];
      example = literalExpression ''
        with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          regex
          kdl
        ];
      '';
      description = ''
        List of treesitter grammars to install. For grammars to be installed properly,
        you must use grammars from `pkgs.vimPlugins.nvim-treesitter.builtGrammars`.
        You can use `pkgs.vimPlugins.nvim-treesitter.allGrammars` to install all grammars.

        For languages already supported by nvf, you may use
        {option}`vim.language.<lang>.treesitter` options, which will automatically add
        the required grammars to this.
      '';
    };

    addDefaultGrammars = mkOption {
      type = bool;
      default = true;
      description = ''
        Whether to add the default grammars to the list of grammars
        to install.

        This option is only relevant if treesitter has been enabled.
      '';
    };

    defaultGrammars = mkOption {
      internal = true;
      readOnly = true;
      type = listOf package;
      default = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [c lua vim vimdoc query];
      description = ''
        A list of treesitter grammars that will be installed by default
        if treesitter has been enabled and  {option}`vim.treeesitter.addDefaultGrammars`
        has been set to true.

        ::: {.note}
        Regardless of which language module options you enable, Neovim
        depends on those grammars to be enabled while treesitter is enabled.

        This list cannot be modified, but if you would like to bring your own
        parsers instead of those provided here, you can set `addDefaultGrammars`
        to false
        :::
      '';
    };

    indent = {
      enable = mkEnableOption "indentation with treesitter" // {default = true;};
      disable = mkOption {
        type = either (listOf str) luaInline;
        default = [];
        example = literalExpression ''["c" "rust"]'';

        description = ''
          List of treesitter grammars to disable indentation for.

          This option can be either a list, in which case it will be
          converted to a Lua table containing grammars to disable
          indentation for, or a string containing a **lua function**
          that will be read as is.

          ::: {.warning}
          A comma will be added at the end of your function, so you
          do not need to add it yourself. Doing so will cause in
          syntax errors within your Neovim configuration.
          :::
        '';
      };
    };

    highlight = {
      enable = mkEnableOption "highlighting with treesitter" // {default = true;};
      disable = mkOption {
        type = either (listOf str) luaInline;
        default = [];
        example = literalMD ''
          ```lua
          -- Disable slow treesitter highlight for large files
          function(lang, buf)
            local max_filesize = 1000 * 1024 -- 1MB
            local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
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

      additionalVimRegexHighlighting = mkOption {
        type = either bool (listOf str);
        default = false;
        description = ''
          Takes either a boolean or a list of languages.

          Setting this to true will run `:h syntax` and tree-sitter at the same time.
          You may this to `true` if you depend on 'syntax' being enabled (like for
          indentation).

          ::: {.note}
          Using this option may slow down your editor, and you may see some duplicate
          highlights.
          :::
        '';
      };
    };

    incrementalSelection = {
      enable = mkEnableOption "incremental selection with treesitter" // {default = true;};
      disable = mkOption {
        type = either (listOf str) luaInline;
        default = [];
        example = literalExpression ''["c" "rust" ]'';

        description = ''
          List of treesitter grammars to disable incremental selection
          for.

          This option can be either a list, in which case it will be
          converted to a Lua table containing grammars to disable
          indentation for, or a string containing a **lua function**
          that will be read as is.

          ::: {.warning}
          A comma will be added at the end of your function, so you
          do not need to add it yourself. Doing so will cause in
          syntax errors within your Neovim configuration.
          :::
        '';
      };
    };
  };
}
