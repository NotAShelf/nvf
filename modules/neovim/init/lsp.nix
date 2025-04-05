{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption;
  inherit (lib.types) attrsOf;
  inherit (lib.strings) concatLines;
  inherit (lib.attrsets) mapAttrsToList attrNames filterAttrs;
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
      description = "";
    };
  };

  config = mkIf (cfg.servers != {}) {
    vim.luaConfigRC.lsp-servers = entryAnywhere ''
      -- Individual LSP configurations managed by nvf.
      ${(concatLines lspConfigurations)}

      -- Enable configured LSPs explicitly
      vim.lsp.enable(${toLuaObject (attrNames enabledServers)})
    '';
  };
}
