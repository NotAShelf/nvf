{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption literalExpression;
  inherit (lib.strings) concatStringsSep trim;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.types) attrsOf;
  inherit (lib.nvim.types) luaInline;

  cfg = config.vim.healthchecks;
in {
  options.vim.healthchecks = mkOption {
    type = attrsOf (attrsOf luaInline);
    default = {};
    description = "custom healthchecks to register";
    example = literalExpression ''
      let
        inherit (lib.generators) mkLuaInline;
      in
      {
        nvf = {
          "Executables" = mkLuaInline '''
            if vim.fn.executable("git") == 1 then
              vim.health.ok("git found")
            else
              vim.health.error("git not found")
            end

            if vim.fn.executable("pijul") == 1 then
              vim.health.ok("pijul found")
            else
              vim.health.error("pijul not found")
            end
          ''';
          "Nixvim" = mkLuaInline '''
            vim.health.ok("NVF is better than nixvim")
          ''';
        };
      }
    '';
  };

  config = mkIf (cfg != {}) {
    vim.additionalRuntimePaths = [
      (pkgs.linkFarm "nvf-healthchecks" (mapAttrsToList (name: checks: {
          name = "lua/${name}/health.lua";
          path = pkgs.writeText "nvf-healthcheck-${name}" ''
            local M = {}

            M.check = function()
              ${concatStringsSep "\n" (mapAttrsToList (name: check: ''
                vim.health.start("${name}")
                ${trim check.expr}
              '')
              checks)}
            end

            return M
          '';
        })
        cfg))
    ];
  };
}
