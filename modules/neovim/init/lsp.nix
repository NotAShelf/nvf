{
  config,
  lib,
  ...
}: let
  inherit (builtins) filter;
  inherit (lib.modules) mkIf mkMerge mkDefault;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) attrsOf;
  inherit (lib.strings) concatLines;
  inherit (lib.attrsets) mapAttrsToList attrNames filterAttrs;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.languages) lspOptions;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.lsp;

  # TODO: lspConfigurations filter on enabledServers instead of cfg.servers?
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
    vim.lsp = {
      enable = mkEnableOption ''
        global LSP functionality for Neovim.

        This option controls whether to enable LSP functionality within modules under
        {option}`vim.languages`. You do not need to set this to `true` for language
        servers defined in {option}`vim.lsp.servers` to take effect, since they are
        enabled automatically.
      '';

      servers = mkOption {
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
          LSP configurations that will be managed using `vim.lsp.config()` and related
          utilities added in Neovim 0.11. LSPs defined here will be added to the
          resulting {file}`init.lua` using `vim.lsp.config` and enabled through
          `vim.lsp.enable()` API from Neovim below the configuration table.

          You may review the generated configuration by running {command}`nvf-print-config`
          in a shell. Please see {command}`:help lsp-config` for more details
          on the underlying API.
        '';
      };
    };
  };

  config = mkMerge [
    {
      vim.lsp.servers."*" = {
        capabilities = mkDefault (mkLuaInline "capabilities");
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
