{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.diagnostics.nvim-lint;
in {
  config = mkMerge [
    (mkIf cfg.enable {
      vim = {
        startPlugins = ["nvim-lint"];
        pluginRC.nvim-lint = entryAnywhere ''
          require("lint").linters_by_ft = ${toLuaObject cfg.linters_by_ft}

          local linters = require("lint").linters
          local nvf_linters = ${toLuaObject cfg.linters}
          for linter, config in pairs(nvf_linters) do
            if linters[linter] == nil then
              linters[linter] = config
            else
              for key, val in pairs(config) do
                linters[linter][key] = val
              end
            end
          end
        '';
      };
    })
    (mkIf (cfg.enable && cfg.lint_after_save) {
      vim = {
        augroups = [{name = "nvf_nvim_lint";}];
        autocmds = [
          {
            event = ["BufWritePost"];
            callback = mkLuaInline ''
              function(args)
                local ft = vim.api.nvim_get_option_value("filetype", { buf = args.buf })
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
                  local cwd = linter.required_files

                  -- if no configuration files are configured, lint
                  if cwd == nil then
                    require("lint").lint(linter)
                  else
                    -- if configuration files are configured and present in the project, lint
                    for _, fn in ipairs(cwd) do
                      if vim.uv.fs_stat(fn) then
                        require("lint").try_lint(name)
                      end
                    end
                  end
                end
              end
            '';
          }
        ];
      };
    })
  ];
}
