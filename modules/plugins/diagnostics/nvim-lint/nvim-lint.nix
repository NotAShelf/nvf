{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) nullOr attrsOf listOf str either submodule bool enum;
  inherit (lib.nvim.types) luaInline;

  linterType = submodule {
    options = {
      name = mkOption {
        type = nullOr str;
        default = null;
        description = "Name of the linter";
      };

      cmd = mkOption {
        type = nullOr str;
        default = null;
        description = "Command of the linter";
      };

      args = mkOption {
        type = nullOr (listOf (either str luaInline));
        default = null;
        description = "Arguments to pass";
      };

      stdin = mkOption {
        type = nullOr bool;
        default = null;
        description = "Send content via stdin.";
      };

      append_fname = mkOption {
        type = nullOr bool;
        default = null;
        description = ''
          Automatically add the current file name to the commands arguments. Only
          has an effect if stdin is false
        '';
      };

      stream = mkOption {
        type = nullOr (enum ["stdout" "stderr" "both"]);
        default = null;
        description = "Result stream";
      };

      ignore_exitcode = mkOption {
        type = nullOr bool;
        default = null;
        description = ''
          Declares if exit code != 1 should be ignored or result in a warning.
        '';
      };

      env = mkOption {
        type = nullOr (attrsOf str);
        default = null;
        description = "Environment variables to use";
      };

      cwd = mkOption {
        type = nullOr str;
        default = null;
        description = "Working directory of the linter";
      };

      parser = mkOption {
        type = nullOr luaInline;
        default = null;
        description = "Parser function";
      };

      required_files = mkOption {
        type = nullOr (listOf str);
        default = null;
        description = "Required files to lint";
        example = ["eslint.config.js"];
      };
    };
  };
in {
  options.vim.diagnostics.nvim-lint = {
    enable = mkEnableOption "asynchronous linter plugin for Neovim [nvim-lint]";

    # nvim-lint does not have a setup table.
    linters_by_ft = mkOption {
      type = attrsOf (listOf str);
      default = {};
      example = {
        text = ["vale"];
        markdown = ["vale"];
      };
      description = ''
        Map of filetype to formatters. This option takes a set of `key = value`
        format where the `value` will be converted to its Lua equivalent
        through `toLuaObject. You are responsible for passing the correct Nix
        data types to generate a correct Lua value that conform is able to
        accept.
      '';
    };

    linters = mkOption {
      type = attrsOf linterType;
      default = {};
      example = ''
        {
          phpcs = {
            args = ["-q" "--report-json" "-"];

            # this will replace the builtin's env table if it exists
            env = {
              ENV_VAR = "something";
            };
          };
        }
      '';

      description = ''
        Linter configurations. Builtin linters will be updated and not
        replaced, but note that this is not a deep extend operation, i.e. if
        you define an `env` option, it will replace the entire `env` table
        provided by the builtin (if it exists).
      '';
    };

    lint_after_save = mkEnableOption "autocmd to lint after each save" // {default = true;};
  };
}
