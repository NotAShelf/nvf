{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.binds) addDescriptionsToMappings;
  inherit (lib.strings) optionalString;
  inherit (lib.lists) optionals;
  inherit (lib.nvim.binds) pushDownDefault mkSetLznBinding;

  cfg = config.vim.telescope;
  self = import ./telescope.nix {inherit pkgs lib;};
  mappingDefinitions = self.options.vim.telescope.mappings;

  mappings = addDescriptionsToMappings cfg.mappings mappingDefinitions;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["plenary-nvim"];

      lazy.plugins.telescope = {
        package = "telescope";
        setupModule = "telescope";
        inherit (cfg) setupOpts;
        # FIXME: how do I deal with extensions? set all as deps?
        after = ''
          local telescope = require("telescope")
          ${optionalString config.vim.ui.noice.enable "telescope.load_extension('noice')"}
          ${optionalString config.vim.notify.nvim-notify.enable "telescope.load_extension('notify')"}
          ${optionalString config.vim.projects.project-nvim.enable "telescope.load_extension('projects')"}
        '';

        cmd = ["Telescope"];

        keys =
          [
            (mkSetLznBinding mappings.findFiles "<cmd> Telescope find_files<CR>")
            (mkSetLznBinding mappings.liveGrep "<cmd> Telescope live_grep<CR>")
            (mkSetLznBinding mappings.buffers "<cmd> Telescope buffers<CR>")
            (mkSetLznBinding mappings.helpTags "<cmd> Telescope help_tags<CR>")
            (mkSetLznBinding mappings.open "<cmd> Telescope<CR>")

            (mkSetLznBinding mappings.gitCommits "<cmd> Telescope git_commits<CR>")
            (mkSetLznBinding mappings.gitBufferCommits "<cmd> Telescope git_bcommits<CR>")
            (mkSetLznBinding mappings.gitBranches "<cmd> Telescope git_branches<CR>")
            (mkSetLznBinding mappings.gitStatus "<cmd> Telescope git_status<CR>")
            (mkSetLznBinding mappings.gitStash "<cmd> Telescope git_stash<CR>")
          ]
          ++ (optionals config.vim.lsp.enable [
            (mkSetLznBinding mappings.lspDocumentSymbols "<cmd> Telescope lsp_document_symbols<CR>")
            (mkSetLznBinding mappings.lspWorkspaceSymbols "<cmd> Telescope lsp_workspace_symbols<CR>")

            (mkSetLznBinding mappings.lspReferences "<cmd> Telescope lsp_references<CR>")
            (mkSetLznBinding mappings.lspImplementations "<cmd> Telescope lsp_implementations<CR>")
            (mkSetLznBinding mappings.lspDefinitions "<cmd> Telescope lsp_definitions<CR>")
            (mkSetLznBinding mappings.lspTypeDefinitions "<cmd> Telescope lsp_type_definitions<CR>")
            (mkSetLznBinding mappings.diagnostics "<cmd> Telescope diagnostics<CR>")
          ])
          ++ (
            optionals config.vim.treesitter.enable [
              (mkSetLznBinding mappings.treesitter "<cmd> Telescope treesitter<CR>")
            ]
          )
          ++ (
            optionals config.vim.projects.project-nvim.enable [
              (mkSetLznBinding mappings.findProjects "<cmd Telescope projects<CR>")
            ]
          );
      };

      binds.whichKey.register = pushDownDefault {
        "<leader>f" = "+Telescope";
        "<leader>fl" = "Telescope LSP";
        "<leader>fm" = "Cellular Automaton";
        "<leader>fv" = "Telescope Git";
        "<leader>fvc" = "Commits";
      };
    };
  };
}
