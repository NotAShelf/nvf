{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.utility.jupytext-nvim;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["jupytext.nvim"];

      extraPackages = [pkgs.python3Packages.jupytext];

      pluginRC.jupytext-nvim = entryAnywhere ''
        require("jupytext").setup(${toLuaObject cfg.setupOpts})

        local jupytext_utils = require("jupytext.utils")
        local language_extensions = {
          python = "py", julia = "jl", r = "r", R = "r", bash = "sh",
        }
        local language_names = { python3 = "python" }

        jupytext_utils.get_ipynb_metadata = function(filename)
          local f = io.open(filename, "r")
          if not f then return { language = "python", extension = "py" } end
          local ok, decoded = pcall(vim.json.decode, f:read("a"))
          f:close()
          if not ok or not decoded or not decoded.metadata then
            return { language = "python", extension = "py" }
          end
          local meta = decoded.metadata
          local language = nil
          if meta.kernelspec then
            language = meta.kernelspec.language
            if not language then
              language = language_names[meta.kernelspec.name]
            end
          end
          if not language and meta.language_info then
            language = meta.language_info.name
          end
          language = language or "python"
          local extension = language_extensions[language] or "py"
          return { language = language, extension = extension }
        end
      '';
    };
  };
}
