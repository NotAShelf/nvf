{lib, ...}: let
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) listOf str int nullOr;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.types) luaInline mkPluginSetupOption;
  inherit (lib.nvim.config) batchRenameOptions;

  migrationTable = {
    debug = "debug";
    diagnostics_format = "diagnostics_format";
    debounce = "debounce";
    default_timeout = "default_timeout";
    sources = "sources";
  };

  renamedSetupOpts =
    batchRenameOptions
    ["vim" "lsp" "null-ls"]
    ["vim" "lsp" "null-ls" "setupOpts"]
    migrationTable;
in {
  imports = renamedSetupOpts;

  options.vim.lsp.null-ls = {
    enable = mkEnableOption ''
      null-ls, plugin to use Neovim as a language server to inject LSP diagnostics,
      code actions, and more via Lua.
    '';

    setupOpts = mkPluginSetupOption "null-ls" {
      debug = mkEnableOption ''
        debugging information for null-ls.

        Displays all possible log messages and writes them to the null-ls log,
        which you can view with the command `:NullLsLog`
      '';

      diagnostics_format = mkOption {
        type = str;
        default = "[#{m}] #{s} (#{c})";
        description = ''
          Sets the default format used for diagnostics. null-ls will replace th
          e following special components with the relevant diagnostic information:

          * `#{m}`: message
          * `#{s}`: source name (defaults to null-ls if not specified)
          * `#{c}`: code (if available)
        '';
      };

      debounce = mkOption {
        type = int;
        default = 250;
        description = ''
          Amount of time between the last change to a buffer and the next `textDocument/didChange` notification.
        '';
      };

      default_timeout = mkOption {
        type = int;
        default = 5000;
        description = ''
          Amount of time (in milliseconds) after which built-in sources will time out.

          :::{.note}
          Built-in sources can define their own timeout period and users can override
          the timeout period on a per-source basis
          :::
        '';
      };

      sources = mkOption {
        type = nullOr (listOf luaInline);
        default = null;
        description = "Sources for null-ls to register";
      };

      on_attach = mkOption {
        type = nullOr luaInline;
        default = mkLuaInline "on_attach";
        description = ''
          Defines an on_attach callback to run whenever null-ls attaches to a buffer.
        '';
      };
    };
  };
}
