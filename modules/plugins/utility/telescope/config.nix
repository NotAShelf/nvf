{
  options,
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.binds) addDescriptionsToMappings;
  inherit (lib.strings) optionalString;
  inherit (lib.lists) optionals;
  inherit (lib.nvim.binds) pushDownDefault mkSetLznBinding;

  cfg = config.vim.telescope;
  mappingDefinitions = options.vim.telescope.mappings;

  mappings = addDescriptionsToMappings cfg.mappings mappingDefinitions;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["plenary-nvim"];

      lazy.plugins.telescope = {
        package = "telescope";
        setupModule = "telescope";
        inherit (cfg) setupOpts;
        after = ''
          local telescope = require("telescope")
          ${optionalString config.vim.ui.noice.enable "telescope.load_extension('noice')"}
          ${optionalString config.vim.notify.nvim-notify.enable "telescope.load_extension('notify')"}
          ${optionalString config.vim.projects.project-nvim.enable "telescope.load_extension('projects')"}
        '';

        cmd = ["Telescope"];

        keys =
          [
            (mkSetLznBinding "n" mappings.findFiles "<cmd> Telescope find_files<CR>")
            (mkSetLznBinding "n" mappings.liveGrep "<cmd> Telescope live_grep<CR>")
            (mkSetLznBinding "n" mappings.buffers "<cmd> Telescope buffers<CR>")
            (mkSetLznBinding "n" mappings.helpTags "<cmd> Telescope help_tags<CR>")
            (mkSetLznBinding "n" mappings.open "<cmd> Telescope<CR>")

            (mkSetLznBinding "n" mappings.gitCommits "<cmd> Telescope git_commits<CR>")
            (mkSetLznBinding "n" mappings.gitBufferCommits "<cmd> Telescope git_bcommits<CR>")
            (mkSetLznBinding "n" mappings.gitBranches "<cmd> Telescope git_branches<CR>")
            (mkSetLznBinding "n" mappings.gitStatus "<cmd> Telescope git_status<CR>")
            (mkSetLznBinding "n" mappings.gitStash "<cmd> Telescope git_stash<CR>")
          ]
          ++ (optionals config.vim.lsp.enable [
            (mkSetLznBinding "n" mappings.lspDocumentSymbols "<cmd> Telescope lsp_document_symbols<CR>")
            (mkSetLznBinding "n" mappings.lspWorkspaceSymbols "<cmd> Telescope lsp_workspace_symbols<CR>")

            (mkSetLznBinding "n" mappings.lspReferences "<cmd> Telescope lsp_references<CR>")
            (mkSetLznBinding "n" mappings.lspImplementations "<cmd> Telescope lsp_implementations<CR>")
            (mkSetLznBinding "n" mappings.lspDefinitions "<cmd> Telescope lsp_definitions<CR>")
            (mkSetLznBinding "n" mappings.lspTypeDefinitions "<cmd> Telescope lsp_type_definitions<CR>")
            (mkSetLznBinding "n" mappings.diagnostics "<cmd> Telescope diagnostics<CR>")
          ])
          ++ (
            optionals config.vim.treesitter.enable [
              (mkSetLznBinding "n" mappings.treesitter "<cmd> Telescope treesitter<CR>")
            ]
          )
          ++ (
            optionals config.vim.projects.project-nvim.enable [
              (mkSetLznBinding "n" mappings.findProjects "<cmd Telescope projects<CR>")
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
