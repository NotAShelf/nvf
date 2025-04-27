{
  config,
  lib,
  ...
}: let
  inherit (builtins) filter;
  inherit (lib.modules) mkIf mkMerge mkDefault;
  inherit (lib.options) mkOption;
  inherit (lib.types) attrsOf;
  inherit (lib.strings) concatLines;
  inherit (lib.attrsets) mapAttrsToList attrNames filterAttrs;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.languages) lspOptions;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.lsp;

  lspConfigurations =
    mapAttrsToList (
      name: value: ''
        vim.lsp.config["${name}"] = ${toLuaObject value}
      ''
    )
    cfg.servers;

  enabledServers = filterAttrs (_: u: u.enable) cfg.servers;
in {
  options = {
    vim.lsp.servers = mkOption {
      type = attrsOf lspOptions;
      default = {};
      example = ''
        {
          "*" = {
            root_markers = [".git"];
            capabilities = {
              textDocument = {
                semanticTokens = {
                  multilineTokenSupport = true;
                };
              };
            };
          };

          "clangd" = {
            filetypes = ["c"];
          };
        }
      '';
      description = ''
        LSP configurations that will be managed using `vim.lsp.config()` and
        related utilities added in Neovim 0.11. LSPs defined here will be
        added to the resulting {file}`init.lua` using `vim.lsp.config` and
        enabled through `vim.lsp.enable` below the configuration table.

        You may review the generated configuration by running {command}`nvf-print-config`
        in a shell. Please see {command}`:help lsp-config` for more details
        on the underlying API.
      '';
    };
  };

  config = mkMerge [
    {
      vim.lsp.servers."*" = {
        capabilities = mkDefault (mkLuaInline "capabilities");
        on_attach = mkDefault (mkLuaInline "default_on_attach");
      };
    }

    (mkIf (cfg.servers != {}) {
      vim.luaConfigRC.lsp-servers = entryAnywhere ''
        -- Individual LSP configurations managed by nvf.
        ${concatLines lspConfigurations}

        -- Enable configured LSPs explicitly
        vim.lsp.enable(${toLuaObject (filter (name: name != "*") (attrNames enabledServers))})
      '';
    })
  ];
}
