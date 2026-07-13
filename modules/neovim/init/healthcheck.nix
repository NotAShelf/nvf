{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption;
  inherit (lib.strings) concatStringsSep replaceStrings trim;
  inherit (lib.attrsets) mapAttrsToList;
  inherit (lib.types) attrsOf;
  inherit (lib.nvim.types) luaInline;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.healthchecks;
in {
  options.vim.healthchecks = mkOption {
    type = attrsOf (attrsOf luaInline);
    default = {};
    description = "custom healthchecks to register";
    example = {
      nvf = {
        "Executables" = mkLuaInline ''
          if vim.fn.executable("git") == 1 then
            vim.health.ok("git found")
          else
            vim.health.error("git not found")
          end
        '';
      };
    };
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
                ${"  " + replaceStrings ["\n"] ["\n  "] (trim check.expr)}
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
