{
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.types) listOf nullOr package bool str lines enum submodule oneOf attrsOf;

  queriesType = submodule {
    options = {
      type = mkOption {
        type = enum ["injections" "highlights" "folds" "locals" "indents"];
        description = "The kind of query to register.";
      };
      filetypes = mkOption {
        type = listOf str;
        default = [];
        description = "The filetypes for which the query should be registered.";
      };
      query = mkOption {
        type = lines;
        description = "The queries scm script.";
      };
    };
  };
in {
  options.vim.treesitter = {
    enable = mkEnableOption "treesitter, also enabled automatically through language options";

    fold = mkEnableOption "fold with treesitter";
    autotagHtml = mkEnableOption "autoclose and rename html tag";

    grammars = mkOption {
      type = listOf (nullOr package);
      default = [];
      example = literalExpression ''
        with pkgs.vimPlugins.nvim-treesitter.grammarPlugins; [
          regex
          kdl
        ];
      '';
      description = ''
        List of treesitter grammars to install. For grammars to be installed properly,
        you must use grammars from one of those:
        - `pkgs.vimPlugins.nvim-treesitter.parsers`
        - `pkgs.vimPlugins.nvim-treesitter.grammarPlugins`
        - `pkgs.tree-sitter-grammars` (mostly untested)

        You can use `pkgs.vimPlugins.nvim-treesitter.allGrammars` to install all grammars shipped with `nvim-treesitter`.

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
      default = with pkgs.vimPlugins.nvim-treesitter.grammarPlugins; [c lua vim vimdoc query];
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
      pattern = mkOption {
        type = oneOf [str (listOf str)];
        default = "*";
        example = literalExpression ''["lua" "nix"]'';
        description = ''
          Specify the filetype pattern(s) for which the treesitter indentation should be used.

          See {command}`:h autocmd-pattern`.
        '';
      };
      excludes = mkOption {
        type = listOf str;
        default = [];
        example = literalExpression ''["haskell", "purescript"]'';
        description = ''
          Exclude the listed filetypes from using treesitter indentation.
        '';
      };
    };

    highlight = {enable = mkEnableOption "highlighting with treesitter" // {default = true;};};

    queries = mkOption {
      type = listOf queriesType;
      default = [];
      description = "A list of Neovim treesitter queries to be registered.";
    };

    filetypeMappings = mkOption {
      type = attrsOf (listOf str);
      default = {};
      example = {
        "sh" = ["ash" "dash"];
      };
      description = ''
        For each parser, registers a list of alternative filetypes.
        For more information see `:h vim.treesitter.language.register()`.
        See treesitter builtin mappings here: <https://github.com/nvim-treesitter/nvim-treesitter/blob/main/plugin/filetypes.lua>
      '';
    };
  };
}
