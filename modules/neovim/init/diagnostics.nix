{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption;
  inherit (lib.types) either bool attrsOf submodule anything str;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.types) luaInline;
  inherit (lib.nvim.dag) entryBefore;

  cfg = config.vim.diagnostics;
in {
  options.vim.diagnostics = {
    enable = mkOption {
      type = either bool luaInline;
      default = false;
      description = ''
        Whether to enable Neovim's built-in diagnostics module.

        [Neovim documentation on diagnostics]: https://neovim.io/doc/user/diagnostic.html)

        Can be either a boolean, or a Lua function that evaluates to
        a boolean. Please refer to [Neovim documentation on diagnostics]
        for more details on this option, and the module as a whole.
      '';
    };

    settings = mkOption {
      default = {};
      type = attrsOf (submodule {
        freeformType = attrsOf anything;
        options = {
          underline = mkOption {
            type = bool;
            default = true;
            description = "Whether to use underline for diagnostics";
          };

          virtual_text = mkOption {
            type = bool;
            default = false;
            description = ''
              Whether to use underline for diagnostics.

              If multiple diagnostics are set for a namespace, one prefix per diagnostic
              plus the last diagnostic message are shown.
            '';
          };

          signs = mkOption {
            type = bool;
            default = true;
            description = "Whether to use signs for diagnostics";
          };
        };
      });

      description = ''
        [`vim.diagnostics.config()`]: https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.config()

        Attribute set of settings that will be converted to a Lua table for
        `vim.diagnostics.config`. Can be overridden with additional options
        as defined in [`vim.diagnostics.config()`] on Neovim manual.
      '';
    };

    signs = let
      mkDiagnosticOption = icon: hl: signVariant:
        mkOption {
          type = attrsOf str;
          default = {inherit icon hl;};
          description = "Diagnostic icon to be used while signs are enabled for ${signVariant}";
        };
    in {
      info = mkDiagnosticOption "󰌵" "DiagnosticSignInfo" "info";
      hint = mkDiagnosticOption "" "DiagnosticsSignHint" "hint";
      warn = mkDiagnosticOption "" "DiagnosticsSignWarn" "warn";
      error = mkDiagnosticOption "" "DiagnosticsSignError" "error";
    };
  };

  config = {
    vim = {
      luaConfigRC.diagnostics = entryBefore ["pluginConfigs"] ''
        vim.diagnostics.config(${toLuaObject cfg.settings})

        local nvf_diagnostics_group = vim.api.nvim_create_augroup("NvfDiagnosticsGroup", { clear = true })
        vim.api.nvim_create_autocmd("BufEnter", {
        	pattern = "*",
          group = nvf_diagnostics_group,
        	callback = function()
        		vim.diagnostics.enable(${toLuaObject cfg.enable})
          end,
        })
      '';
    };
  };
}
