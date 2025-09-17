{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.types) nullOr attrsOf listOf str either submodule bool enum;
  inherit (lib.nvim.types) luaInline;
  inherit (lib.generators) mkLuaInline;

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
        example = ["eslint.config.js"];
        description = ''
          Required files to lint. These files must exist relative to the cwd
          of the linter or else this linter will be skipped

          ::: {.note}
          This option is an nvf extension that only takes effect if you
          use the `nvf_lint()` lua function.

          See {option}`vim.diagnostics.nvim-lint.lint_function`.
          :::
        '';
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

    lint_function = mkOption {
      type = luaInline;
      default = mkLuaInline ''
        function(buf)
          local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
          local linters = require("lint").linters
          local linters_from_ft = require("lint").linters_by_ft[ft]

          -- if no linter is configured for this filetype, stops linting
          if linters_from_ft == nil then return end

          for _, name in ipairs(linters_from_ft) do
            local linter = linters[name]
            assert(linter, 'Linter with name `' .. name .. '` not available')

            if type(linter) == "function" then
              linter = linter()
            end
            -- for require("lint").lint() to work, linter.name must be set
            linter.name = linter.name or name
            local cwd = linter.required_files

            -- if no configuration files are configured, lint
            if cwd == nil then
              require("lint").lint(linter)
            else
              -- if configuration files are configured and present in the project, lint
              for _, fn in ipairs(cwd) do
                local path = vim.fs.joinpath(linter.cwd or vim.fn.getcwd(), fn);
                if vim.uv.fs_stat(path) then
                  require("lint").lint(linter)
                  break
                end
              end
            end
          end
        end
      '';
      example = literalExpression ''
        mkLuaInline '''
          function(buf)
            require("lint").try_lint()
          end
        '''
      '';
      description = "Define the global function nvf_lint which is used by nvf to lint.";
    };
  };
}
