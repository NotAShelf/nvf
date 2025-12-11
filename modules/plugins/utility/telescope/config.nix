{
  options,
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.strings) optionalString concatMapStringsSep;
  inherit (lib.lists) optionals concatLists;
  inherit (lib.nvim.binds) pushDownDefault mkKeymap;

  cfg = config.vim.telescope;

  keys = cfg.mappings;
  inherit (options.vim.telescope) mappings;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["plenary-nvim"] ++ concatLists (map (x: x.packages) cfg.extensions);

      lazy.plugins.telescope = {
        package = "telescope";
        setupModule = "telescope";
        inherit (cfg) setupOpts;

        # HACK: workaround until https://github.com/NotAShelf/nvf/issues/535 gets resolved
        before = ''
          vim.g.loaded_telescope = nil
        '';

        after = let
          enabledExtensions = map (x: x.name) cfg.extensions;
        in ''
          local telescope = require("telescope")
          ${optionalString config.vim.ui.noice.enable "telescope.load_extension('noice')"}
          ${optionalString config.vim.notify.nvim-notify.enable "telescope.load_extension('notify')"}
          ${optionalString config.vim.projects.project-nvim.enable "telescope.load_extension('projects')"}
          ${concatMapStringsSep "\n" (x: "telescope.load_extension('${x}')") enabledExtensions}
        '';

        cmd = ["Telescope"];

        keys =
          [
            (mkKeymap "n" keys.findFiles "<cmd>Telescope find_files<CR>" {desc = mappings.findFiles.description;})
            (mkKeymap "n" keys.liveGrep "<cmd>Telescope live_grep<CR>" {desc = mappings.liveGrep.description;})
            (mkKeymap "n" keys.buffers "<cmd>Telescope buffers<CR>" {desc = mappings.buffers.description;})
            (mkKeymap "n" keys.helpTags "<cmd>Telescope help_tags<CR>" {desc = mappings.helpTags.description;})
            (mkKeymap "n" keys.open "<cmd>Telescope<CR>" {desc = mappings.open.description;})
            (mkKeymap "n" keys.resume "<cmd>Telescope resume<CR>" {desc = mappings.resume.description;})

            (mkKeymap "n" keys.gitFiles "<cmd>Telescope git_files<CR>" {desc = mappings.gitFiles.description;})
            (mkKeymap "n" keys.gitCommits "<cmd>Telescope git_commits<CR>" {desc = mappings.gitCommits.description;})
            (mkKeymap "n" keys.gitBufferCommits "<cmd>Telescope git_bcommits<CR>" {desc = mappings.gitBufferCommits.description;})
            (mkKeymap "n" keys.gitBranches "<cmd>Telescope git_branches<CR>" {desc = mappings.gitBranches.description;})
            (mkKeymap "n" keys.gitStatus "<cmd>Telescope git_status<CR>" {desc = mappings.gitStatus.description;})
            (mkKeymap "n" keys.gitStash "<cmd>Telescope git_stash<CR>" {desc = mappings.gitStash.description;})
          ]
          ++ (optionals config.vim.lsp.enable [
            (mkKeymap "n" keys.lspDocumentSymbols "<cmd>Telescope lsp_document_symbols<CR>" {desc = mappings.lspDocumentSymbols.description;})
            (mkKeymap "n" keys.lspWorkspaceSymbols "<cmd>Telescope lsp_workspace_symbols<CR>" {desc = mappings.lspWorkspaceSymbols.description;})

            (mkKeymap "n" keys.lspReferences "<cmd>Telescope lsp_references<CR>" {desc = mappings.lspReferences.description;})
            (mkKeymap "n" keys.lspImplementations "<cmd>Telescope lsp_implementations<CR>" {desc = mappings.lspImplementations.description;})
            (mkKeymap "n" keys.lspDefinitions "<cmd>Telescope lsp_definitions<CR>" {desc = mappings.lspDefinitions.description;})
            (mkKeymap "n" keys.lspTypeDefinitions "<cmd>Telescope lsp_type_definitions<CR>" {desc = mappings.lspTypeDefinitions.description;})
            (mkKeymap "n" keys.diagnostics "<cmd>Telescope diagnostics<CR>" {desc = mappings.diagnostics.description;})
          ])
          ++ optionals config.vim.treesitter.enable [
            (mkKeymap "n" keys.treesitter "<cmd>Telescope treesitter<CR>" {desc = mappings.treesitter.description;})
          ]
          ++ optionals config.vim.projects.project-nvim.enable [
            (mkKeymap "n" keys.findProjects "<cmd>Telescope projects<CR>" {desc = mappings.findProjects.description;})
          ];
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
