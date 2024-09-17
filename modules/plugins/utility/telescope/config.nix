{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.binds) addDescriptionsToMappings mkSetBinding;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.binds) pushDownDefault;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.telescope;
  self = import ./telescope.nix {inherit pkgs lib;};
  mappingDefinitions = self.options.vim.telescope.mappings;

  mappings = addDescriptionsToMappings cfg.mappings mappingDefinitions;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [
        "telescope"
        "plenary-nvim"
      ];

      maps.normal = mkMerge [
        (mkSetBinding mappings.findFiles "<cmd> Telescope find_files<CR>")
        (mkSetBinding mappings.liveGrep "<cmd> Telescope live_grep<CR>")
        (mkSetBinding mappings.buffers "<cmd> Telescope buffers<CR>")
        (mkSetBinding mappings.helpTags "<cmd> Telescope help_tags<CR>")
        (mkSetBinding mappings.open "<cmd> Telescope<CR>")
        (mkSetBinding mappings.resume "<cmd> Telescope resume<CR>")

        (mkSetBinding mappings.gitCommits "<cmd> Telescope git_commits<CR>")
        (mkSetBinding mappings.gitBufferCommits "<cmd> Telescope git_bcommits<CR>")
        (mkSetBinding mappings.gitBranches "<cmd> Telescope git_branches<CR>")
        (mkSetBinding mappings.gitStatus "<cmd> Telescope git_status<CR>")
        (mkSetBinding mappings.gitStash "<cmd> Telescope git_stash<CR>")

        (mkIf config.vim.lsp.enable (mkMerge [
          (mkSetBinding mappings.lspDocumentSymbols "<cmd> Telescope lsp_document_symbols<CR>")
          (mkSetBinding mappings.lspWorkspaceSymbols "<cmd> Telescope lsp_workspace_symbols<CR>")

          (mkSetBinding mappings.lspReferences "<cmd> Telescope lsp_references<CR>")
          (mkSetBinding mappings.lspImplementations "<cmd> Telescope lsp_implementations<CR>")
          (mkSetBinding mappings.lspDefinitions "<cmd> Telescope lsp_definitions<CR>")
          (mkSetBinding mappings.lspTypeDefinitions "<cmd> Telescope lsp_type_definitions<CR>")
          (mkSetBinding mappings.diagnostics "<cmd> Telescope diagnostics<CR>")
        ]))

        (
          mkIf config.vim.treesitter.enable
          (mkSetBinding mappings.treesitter "<cmd> Telescope treesitter<CR>")
        )

        (
          mkIf config.vim.projects.project-nvim.enable
          (mkSetBinding mappings.findProjects "<cmd> Telescope projects<CR>")
        )
      ];

      binds.whichKey.register = pushDownDefault {
        "<leader>f" = "+Telescope";
        "<leader>fl" = "Telescope LSP";
        "<leader>fm" = "Cellular Automaton";
        "<leader>fv" = "Telescope Git";
        "<leader>fvc" = "Commits";
      };

      pluginRC.telescope = entryAnywhere ''
        local telescope = require('telescope')
        telescope.setup(${toLuaObject cfg.setupOpts})

        ${
          if config.vim.ui.noice.enable
          then "telescope.load_extension('noice')"
          else ""
        }

        ${
          if config.vim.notify.nvim-notify.enable
          then "telescope.load_extension('notify')"
          else ""
        }

        ${
          if config.vim.projects.project-nvim.enable
          then "telescope.load_extension('projects')"
          else ""
        }
      '';
    };
  };
}
