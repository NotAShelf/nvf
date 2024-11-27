{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkRenamedOptionModule;
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.types) int bool str nullOr either listOf attrsOf;

  cfg = config.vim.visuals;
in {
  imports = [
    (mkRenamedOptionModule ["vim" "visuals" "indentBlankline"] ["vim" "visuals" "indent-blankline"])
  ];

  options.vim.visuals.indent-blankline = {
    enable = mkEnableOption "indentation guides [indent-blankline]";
    setupOpts = {
      debounce = mkOption {
        type = int;
        description = "Debounce time in milliseconds";
        default = 200;
      };

      viewport_buffer = {
        min = mkOption {
          type = int;
          description = "Number of lines above and below of what is currently
            visible in the window";
          default = 30;
        };

        max = mkOption {
          type = int;
          description = "Number of lines above and below of what is currently
            visible in the window";
          default = 500;
        };
      };

      indent = {
        char = mkOption {
          type = either str (listOf str);
          description = "Character(s) for indentation guide";
          default = "│";
        };

        tab_char = mkOption {
          type = nullOr (either str (listOf str));
          description = ''
            Character(s) for tab indentation guide.

            See `:help ibl.config.indent.tab_char`.
          '';
          default = null;
        };

        highlight = mkOption {
          type = nullOr (either str (listOf str));
          description = ''
            The highlight group(s) applied to the indentation guide.

            See `:help ibl.config.indent.highlight`.
          '';
          default = null;
        };

        smart_indent_cap = mkOption {
          type = bool;
          description = "Caps the number of indentation levels based on surrounding code";
          default = true;
        };

        priority = mkOption {
          type = int;
          description = "Virtual text priority for the indentation guide";
          default = 1;
        };

        repeat_linebreak = mkOption {
          type = bool;
          description = "Repeat indentation guides on wrapped lines";
          default = true;
        };
      };

      whitespace = {
        highlight = mkOption {
          type = nullOr (either str (listOf str));
          description = ''
            The highlight group(s) applied to whitespace.

            See `:help ibl.config.whitespace.highlight`.
          '';
          default = null;
        };

        remove_blankline_trail = mkOption {
          type = bool;
          description = "Remove trailing whitespace on blanklines";
          default = true;
        };
      };

      scope = {
        enabled = mkOption {
          description = "Highlight current scope from treesitter";
          type = bool;
          default = config.vim.treesitter.enable;
          defaultText = literalExpression "config.vim.treesitter.enable";
        };

        char = mkOption {
          type = either str (listOf str);
          description = "The character(s) for the scope indentation guide";
          default = cfg.indent-blankline.setupOpts.indent.char;
          defaultText = literalExpression "config.vim.visuals.indent-blankline.setupOpts.indent.char";
        };

        show_start = mkOption {
          type = bool;
          description = "Show an underline on the first line of the scope";
          default = false;
        };

        show_end = mkOption {
          type = bool;
          description = "Show an underline on the last line of the scope";
          default = false;
        };

        show_exact_scope = mkOption {
          type = bool;
          description = "Show the scope underline at the exact start of the scope, even if that's to the right of the indentation guide";
          default = false;
        };

        injected_languages = mkOption {
          type = bool;
          description = "Check for injected languages (treesitter)";
          default = config.vim.treesitter.enable;
          defaultText = literalExpression "config.vim.treesitter.enable";
        };

        highlight = mkOption {
          type = nullOr (either str (listOf str));
          description = ''
            The highlight group(s) applied to the scope.

            See `:help `ibl.config.scope.highlight`.
          '';
          default = null;
        };

        priority = mkOption {
          type = int;
          description = "Virtual text priority for the scope";
          default = 1024;
        };

        include.node_type = mkOption {
          type = attrsOf (listOf str);
          description = "Additional nodes to be used for scope checking, per language";
          default = {};
        };

        exclude = {
          language = mkOption {
            type = listOf str;
            description = ''
              The list of treesitter languages to disable scope for.

              `*` can be used as a wildcard for every language/node type.
            '';
            default = [];
          };

          node_type = mkOption {
            type = attrsOf (listOf str);
            description = ''
              Nodes to ignore in scope checking, per language.

              `*` can be used as a wildcard for every language.
            '';
            default = {
              "*" = ["source_file" "program"];
              lua = ["chunk"];
              python = ["module"];
            };
          };
        };
      };
    };
  };
}
