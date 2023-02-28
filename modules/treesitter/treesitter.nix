{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.treesitter;
in {
  options.vim.treesitter = {
    enable = mkOption {
      default = false;
      type = types.bool;
      description = "enable tree-sitter [nvim-treesitter]";
    };

    fold = mkOption {
      default = false;
      type = types.bool;
      description = "enable fold with tree-sitter";
    };

    autotagHtml = mkOption {
      default = false;
      type = types.bool;
      description = "enable autoclose and rename html tag [nvim-ts-autotag]";
    };

    grammars = mkOption {
      type = with types; listOf package;
      default = with (pkgs.vimPlugins.nvim-treesitter.builtGrammars);
        [
          c
          cpp
          nix
          python
          rust
          markdown
          comment
          toml
          make
          tsx
          html
          javascript
          css
          graphql
          json
          zig
        ]
        ++ (optional config.vim.notes.orgmode.enable org); # add orgmode grammar if enabled
      description = ''
        List of treesitter grammars to install.
        When enabling a language, its treesitter grammar is added for you.
      '';
    };
  };
}
