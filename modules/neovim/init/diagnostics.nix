{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.types) attrsOf anything oneOf bool submodule;
  inherit (lib.nvim.dag) entryAfter;
  inherit (lib.nvim.types) luaInline;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.diagnostics;

  # Takes a boolean, a table, or a Lua list ({key = value}). We
  # would like to allow all of those types, while clearly expressing
  # them in the option's type. As such, this type is what it is.
  diagnosticType = oneOf [(attrsOf anything) bool luaInline];
  diagnosticsSubmodule = submodule {
    # The table might need to be extended, so let's allow that case
    # with a freeform type of what is supported by diagnostics opts.
    freeformType = attrsOf diagnosticType;
    options = {
      underline = mkOption {
        type = diagnosticType;
        default = true;
        description = "Use underline for diagnostics.";
      };

      virtual_text = mkOption {
        type = diagnosticType;
        default = false;
        example = literalExpression ''
          {
            format = lib.generators.mkLuaInline '''
              function(diagnostic)
                return string.format("%s (%s)", diagnostic.message, diagnostic.source)
              end
            ''';
          }
        '';

        description = ''
          Use virtual text for diagnostics. If multiple diagnostics are set for a namespace,
          one prefix per diagnostic + the last diagnostic message are shown.
        '';
      };

      virtual_lines = mkOption {
        type = diagnosticType;
        default = false;
        description = ''
          Use virtual lines for diagnostics.
        '';
      };

      signs = mkOption {
        type = diagnosticType;
        default = false;
        example = {
          signs.text = {
            "vim.diagnostic.severity.ERROR" = "󰅚 ";
            "vim.diagnostic.severity.WARN" = "󰀪 ";
          };
        };
        description = ''
          Use signs for diagnostics. See {command}`:help diagnostic-signs`.
        '';
      };

      update_in_insert = mkOption {
        type = bool;
        default = false;
        description = ''
          Update diagnostics in Insert mode. If `false`, diagnostics will
          be updated on InsertLeave ({command}`:help InsertLeave`).
        '';
      };
    };
  };
in {
  options.vim = {
    diagnostics = {
      enable = mkEnableOption "diagostics module for Neovim";
      config = mkOption {
        type = diagnosticsSubmodule;
        default = {};
        description = ''
          Values that will be passed to `vim.diagnostic.config` after being converted
          to a Lua table. Possible values for each key can be found in the help text
          for `vim.diagnostics.Opts`. You may find more about the diagnostics API of
          Neovim in {command}`:help diagnostic-api`.

          :::{.note}
          This option is freeform. You may set values that are not present in nvf
          documentation, but those values will not be fully type checked. Please
          refer to the help text for `vim.diagnostic.Opts` for appropriate values.
          :::
        '';
      };
    };
  };

  config.vim = mkIf cfg.enable {
    luaConfigRC.diagnostics = entryAfter ["basic"] ''
      vim.diagnostic.config(${toLuaObject cfg.config})
    '';
  };
}
