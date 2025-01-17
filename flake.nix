{
  description = "A neovim flake with a modular configuration";
  outputs = {
    flake-parts,
    self,
    ...
  } @ inputs: let
    # call the extended library with `inputs`
    # inputs is used to get the original standard library, and to pass inputs to the plugin autodiscovery function
    lib = import ./lib/stdlib-extended.nix inputs;
  in
    flake-parts.lib.mkFlake {
      inherit inputs;
      specialArgs = {inherit lib;};
    } {
      # Allow users to bring their own systems.
      # «https://github.com/nix-systems/nix-systems»
      systems = import inputs.systems;
      imports = [
        ./flake/apps.nix
        ./flake/legacyPackages.nix
        ./flake/overlays.nix
        ./flake/packages.nix
        ./flake/develop.nix
      ];

      flake = {
        lib = {
          inherit (lib) nvim;
          inherit (lib.nvim) neovimConfiguration;
        };

        homeManagerModules = {
          nvf = import ./flake/modules/home-manager.nix {inherit lib self;};
          default = self.homeManagerModules.nvf;
          neovim-flake =
            lib.warn ''
              'homeManagerModules.neovim-flake' has been deprecated, and will be removed
              in a future release. Please use 'homeManagerModules.nvf' instead.
            ''
            self.homeManagerModules.nvf;
        };

        nixosModules = {
          nvf = import ./flake/modules/nixos.nix {inherit lib self;};
          default = self.nixosModules.nvf;
          neovim-flake =
            lib.warn ''
              'nixosModules.neovim-flake' has been deprecated, and will be removed
              in a future release. Please use 'nixosModules.nvf' instead.
            ''
            self.nixosModules.nvf;
        };
      };

      perSystem = {pkgs, ...}: {
        # Provide the default formatter. `nix fmt` in project root
        # will format available files with the correct formatter.
        # P.S: Please do not format with nixfmt! It messes with many
        # syntax elements and results in unreadable code.
        formatter = pkgs.alejandra;

        # Check if codebase is properly formatted.
        # This can be initiated with `nix build .#checks.<system>.nix-fmt`
        # or with `nix flake check`
        checks = {
          nix-fmt = pkgs.runCommand "nix-fmt-check" {nativeBuildInputs = [pkgs.alejandra];} ''
            alejandra --check ${self} < /dev/null | tee $out
          '';
        };
      };
    };

  # Flake inputs
  inputs = {
    ## Basic Inputs
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils.url = "github:numtide/flake-utils";
    systems.url = "github:nix-systems/default";

    # Alternate neovim-wrapper
    mnw.url = "github:Gerg-L/mnw";

    # For generating documentation website
    nmd = {
      url = "sourcehut:~rycee/nmd";
      flake = false;
    };

    # Language servers (use master instead of nixpkgs)
    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    ## Plugins
    # Lazy loading
    plugin-lz-n = {
      url = "github:nvim-neorocks/lz.n";
      flake = false;
    };

    plugin-lzn-auto-require = {
      url = "github:horriblename/lzn-auto-require/require-rewrite";
      flake = false;
    };

    plugin-rtp-nvim = {
      url = "github:nvim-neorocks/rtp.nvim";
      flake = false;
    };

    # LSP plugins
    plugin-nvim-lspconfig = {
      url = "github:neovim/nvim-lspconfig";
      flake = false;
    };

    plugin-lspsaga = {
      url = "github:tami5/lspsaga.nvim";
      flake = false;
    };

    plugin-lspkind = {
      url = "github:onsails/lspkind-nvim";
      flake = false;
    };

    plugin-trouble = {
      url = "github:folke/trouble.nvim";
      flake = false;
    };

    plugin-nvim-treesitter-context = {
      url = "github:nvim-treesitter/nvim-treesitter-context";
      flake = false;
    };

    plugin-nvim-lightbulb = {
      url = "github:kosayoda/nvim-lightbulb";
      flake = false;
    };

    plugin-fastaction-nvim = {
      url = "github:Chaitanyabsprip/fastaction.nvim";
      flake = false;
    };

    plugin-lsp-signature = {
      url = "github:ray-x/lsp_signature.nvim";
      flake = false;
    };

    plugin-lsp-lines = {
      url = "sourcehut:~whynothugo/lsp_lines.nvim";
      flake = false;
    };

    plugin-none-ls = {
      # https://github.com/nvimtools/none-ls.nvim/issues/58
      url = "github:nvimtools/none-ls.nvim/bb680d752cec37949faca7a1f509e2fe67ab418a";
      flake = false;
    };

    plugin-nvim-docs-view = {
      url = "github:amrbashir/nvim-docs-view";
      flake = false;
    };

    plugin-otter-nvim = {
      url = "github:jmbuhr/otter.nvim";
      flake = false;
    };

    # Language support
    plugin-sqls-nvim = {
      url = "github:nanotee/sqls.nvim";
      flake = false;
    };

    plugin-rustaceanvim = {
      url = "github:mrcjkb/rustaceanvim";
      flake = false;
    };

    plugin-flutter-tools = {
      url = "github:akinsho/flutter-tools.nvim";
      flake = false;
    };

    plugin-neodev-nvim = {
      url = "github:folke/neodev.nvim";
      flake = false;
    };

    plugin-elixir-tools = {
      url = "github:elixir-tools/elixir-tools.nvim";
      flake = false;
    };

    plugin-ts-error-translator = {
      url = "github:dmmulroy/ts-error-translator.nvim";
      flake = false;
    };

    plugin-typst-preview-nvim = {
      url = "github:chomosuke/typst-preview.nvim";
      flake = false;
    };

    plugin-nvim-metals = {
      url = "github:scalameta/nvim-metals";
      flake = false;
    };

    plugin-omnisharp-extended = {
      url = "github:Hoffs/omnisharp-extended-lsp.nvim";
      flake = false;
    };

    plugin-csharpls-extended = {
      url = "github:Decodetalkers/csharpls-extended-lsp.nvim";
      flake = false;
    };

    # Copying/Registers
    plugin-registers = {
      url = "github:tversteeg/registers.nvim";
      flake = false;
    };

    plugin-nvim-neoclip = {
      url = "github:AckslD/nvim-neoclip.lua";
      flake = false;
    };

    # Telescope
    plugin-telescope = {
      url = "github:nvim-telescope/telescope.nvim";
      flake = false;
    };

    # Runners
    plugin-run-nvim = {
      url = "github:diniamo/run.nvim";
      flake = false;
    };

    # Debuggers
    plugin-nvim-dap = {
      url = "github:mfussenegger/nvim-dap";
      flake = false;
    };

    plugin-nvim-dap-ui = {
      url = "github:rcarriga/nvim-dap-ui";
      flake = false;
    };

    plugin-nvim-dap-go = {
      url = "github:leoluz/nvim-dap-go";
      flake = false;
    };

    # Filetrees
    plugin-nvim-tree-lua = {
      url = "github:nvim-tree/nvim-tree.lua";
      flake = false;
    };

    plugin-neo-tree-nvim = {
      url = "github:nvim-neo-tree/neo-tree.nvim";
      flake = false;
    };

    # Tablines
    plugin-nvim-bufferline-lua = {
      url = "github:akinsho/nvim-bufferline.lua";
      flake = false;
    };

    # Statuslines
    plugin-lualine = {
      url = "github:hoob3rt/lualine.nvim";
      flake = false;
    };

    plugin-nvim-cmp = {
      url = "github:hrsh7th/nvim-cmp";
      flake = false;
    };

    plugin-cmp-buffer = {
      url = "github:hrsh7th/cmp-buffer";
      flake = false;
    };

    plugin-cmp-nvim-lsp = {
      url = "github:hrsh7th/cmp-nvim-lsp";
      flake = false;
    };

    plugin-cmp-path = {
      url = "github:hrsh7th/cmp-path";
      flake = false;
    };

    plugin-cmp-treesitter = {
      url = "github:ray-x/cmp-treesitter";
      flake = false;
    };

    plugin-cmp-luasnip = {
      url = "github:saadparwaiz1/cmp_luasnip";
      flake = false;
    };

    # snippets
    plugin-luasnip = {
      url = "github:L3MON4D3/LuaSnip";
      flake = false;
    };

    plugin-friendly-snippets = {
      url = "github:rafamadriz/friendly-snippets";
      flake = false;
    };

    # Presence
    plugin-neocord = {
      url = "github:IogaMaster/neocord";
      flake = false; # uses flake-utils, avoid the flake
    };

    # Autopairs
    plugin-nvim-autopairs = {
      url = "github:windwp/nvim-autopairs";
      flake = false;
    };

    plugin-nvim-ts-autotag = {
      url = "github:windwp/nvim-ts-autotag";
      flake = false;
    };

    # Commenting
    plugin-comment-nvim = {
      url = "github:numToStr/Comment.nvim";
      flake = false;
    };

    plugin-todo-comments = {
      url = "github:folke/todo-comments.nvim";
      flake = false;
    };

    # Buffer tools
    plugin-bufdelete-nvim = {
      url = "github:famiu/bufdelete.nvim";
      flake = false;
    };

    # Dashboard Utilities
    plugin-dashboard-nvim = {
      url = "github:glepnir/dashboard-nvim";
      flake = false;
    };

    plugin-alpha-nvim = {
      url = "github:goolord/alpha-nvim";
      flake = false;
    };

    plugin-vim-startify = {
      url = "github:mhinz/vim-startify";
      flake = false;
    };

    # Themes
    plugin-base16 = {
      url = "github:rrethy/base16-nvim";
      flake = false;
    };

    plugin-tokyonight = {
      url = "github:folke/tokyonight.nvim";
      flake = false;
    };

    plugin-onedark = {
      url = "github:navarasu/onedark.nvim";
      flake = false;
    };

    plugin-catppuccin = {
      url = "github:catppuccin/nvim";
      flake = false;
    };

    plugin-dracula = {
      url = "github:Mofiqul/dracula.nvim";
      flake = false;
    };

    plugin-oxocarbon = {
      url = "github:nyoom-engineering/oxocarbon.nvim";
      flake = false;
    };

    plugin-gruvbox = {
      url = "github:ellisonleao/gruvbox.nvim";
      flake = false;
    };

    plugin-rose-pine = {
      url = "github:rose-pine/neovim";
      flake = false;
    };

    plugin-nord = {
      url = "github:gbprod/nord.nvim";
      flake = false;
    };

    # Rust crates
    plugin-crates-nvim = {
      url = "github:Saecki/crates.nvim";
      flake = false;
    };

    # Project Management
    plugin-project-nvim = {
      url = "github:ahmedkhalf/project.nvim";
      flake = false;
    };

    # Visuals
    plugin-nvim-cursorline = {
      url = "github:yamatsum/nvim-cursorline";
      flake = false;
    };

    plugin-nvim-scrollbar = {
      url = "github:petertriho/nvim-scrollbar";
      flake = false;
    };

    plugin-cinnamon-nvim = {
      url = "github:declancm/cinnamon.nvim";
      flake = false;
    };

    plugin-cellular-automaton = {
      url = "github:Eandrju/cellular-automaton.nvim";
      flake = false;
    };

    plugin-indent-blankline = {
      url = "github:lukas-reineke/indent-blankline.nvim";
      flake = false;
    };

    plugin-nvim-web-devicons = {
      url = "github:nvim-tree/nvim-web-devicons";
      flake = false;
    };

    plugin-tiny-devicons-auto-colors = {
      url = "github:rachartier/tiny-devicons-auto-colors.nvim";
      flake = false;
    };

    plugin-gitsigns-nvim = {
      url = "github:lewis6991/gitsigns.nvim";
      flake = false;
    };

    plugin-vim-fugitive = {
      url = "github:tpope/vim-fugitive";
      flake = false;
    };

    plugin-fidget-nvim = {
      url = "github:j-hui/fidget.nvim";
      flake = false;
    };

    plugin-highlight-undo = {
      url = "github:tzachar/highlight-undo.nvim";
      flake = false;
    };

    plugin-render-markdown-nvim = {
      url = "github:MeanderingProgrammer/render-markdown.nvim";
      flake = false;
    };

    # Minimap
    plugin-minimap-vim = {
      url = "github:wfxr/minimap.vim";
      flake = false;
    };

    plugin-codewindow-nvim = {
      url = "github:gorbit99/codewindow.nvim";
      flake = false;
    };

    # Notifications
    plugin-nvim-notify = {
      url = "github:rcarriga/nvim-notify";
      flake = false;
    };

    # Utilities
    plugin-ccc = {
      url = "github:uga-rosa/ccc.nvim";
      flake = false;
    };

    plugin-diffview-nvim = {
      url = "github:sindrets/diffview.nvim";
      flake = false;
    };

    plugin-icon-picker-nvim = {
      url = "github:ziontee113/icon-picker.nvim";
      flake = false;
    };

    plugin-which-key = {
      url = "github:folke/which-key.nvim";
      flake = false;
    };

    plugin-cheatsheet-nvim = {
      url = "github:sudormrfbin/cheatsheet.nvim";
      flake = false;
    };

    plugin-gesture-nvim = {
      url = "github:notomo/gesture.nvim";
      flake = false;
    };

    plugin-hop-nvim = {
      url = "github:phaazon/hop.nvim";
      flake = false;
    };

    plugin-leap-nvim = {
      url = "github:ggandor/leap.nvim";
      flake = false;
    };

    plugin-smartcolumn = {
      url = "github:m4xshen/smartcolumn.nvim";
      flake = false;
    };

    plugin-nvim-surround = {
      url = "github:kylechui/nvim-surround";
      flake = false;
    };

    plugin-glow-nvim = {
      url = "github:ellisonleao/glow.nvim";
      flake = false;
    };

    plugin-image-nvim = {
      url = "github:3rd/image.nvim";
      flake = false;
    };

    plugin-precognition-nvim = {
      url = "github:tris203/precognition.nvim";
      flake = false;
    };

    # Note-taking
    plugin-obsidian-nvim = {
      url = "github:epwalsh/obsidian.nvim";
      flake = false;
    };

    plugin-orgmode-nvim = {
      url = "github:nvim-orgmode/orgmode";
      flake = false;
    };

    plugin-mind-nvim = {
      url = "github:phaazon/mind.nvim";
      flake = false;
    };

    # Spellchecking
    plugin-vim-dirtytalk = {
      url = "github:psliwka/vim-dirtytalk";
      flake = false;
    };

    # Terminal
    plugin-toggleterm-nvim = {
      url = "github:akinsho/toggleterm.nvim";
      flake = false;
    };

    # UI
    plugin-nvim-navbuddy = {
      url = "github:SmiteshP/nvim-navbuddy";
      flake = false;
    };

    plugin-nvim-navic = {
      url = "github:SmiteshP/nvim-navic";
      flake = false;
    };

    plugin-noice-nvim = {
      url = "github:folke/noice.nvim";
      flake = false;
    };

    plugin-modes-nvim = {
      url = "github:mvllow/modes.nvim";
      flake = false;
    };

    plugin-nvim-colorizer-lua = {
      url = "github:NvChad/nvim-colorizer.lua";
      flake = false;
    };

    plugin-vim-illuminate = {
      url = "github:RRethy/vim-illuminate";
      flake = false;
    };

    # Assistant
    plugin-chatgpt = {
      url = "github:jackMort/ChatGPT.nvim";
      flake = false;
    };

    plugin-copilot-lua = {
      url = "github:zbirenbaum/copilot.lua";
      flake = false;
    };

    plugin-copilot-cmp = {
      url = "github:zbirenbaum/copilot-cmp";
      flake = false;
    };

    # Session management
    plugin-nvim-session-manager = {
      url = "github:Shatur/neovim-session-manager";
      flake = false;
    };

    # Dependencies
    plugin-plenary-nvim = {
      # (required by crates-nvim)
      url = "github:nvim-lua/plenary.nvim";
      flake = false;
    };

    plugin-dressing-nvim = {
      # (required by icon-picker-nvim)
      url = "github:stevearc/dressing.nvim";
      flake = false;
    };

    plugin-vim-markdown = {
      # (required by obsidian-nvim)
      url = "github:preservim/vim-markdown";
      flake = false;
    };

    plugin-tabular = {
      # (required by vim-markdown)
      url = "github:godlygeek/tabular";
      flake = false;
    };

    plugin-lua-utils-nvim = {
      url = "github:nvim-neorg/lua-utils.nvim";
      flake = false;
    };

    plugin-pathlib-nvim = {
      url = "github:pysan3/pathlib.nvim";
      flake = false;
    };

    plugin-neorg = {
      url = "github:nvim-neorg/neorg";
      flake = false;
    };

    plugin-neorg-telescope = {
      url = "github:nvim-neorg/neorg-telescope";
      flake = false;
    };

    plugin-nui-nvim = {
      # (required by noice.nvim)
      url = "github:MunifTanjim/nui.nvim";
      flake = false;
    };

    plugin-vim-repeat = {
      # (required by leap.nvim)
      url = "github:tpope/vim-repeat";
      flake = false;
    };

    plugin-nvim-nio = {
      # (required by nvim-dap-ui)
      url = "github:nvim-neotest/nvim-nio";
      flake = false;
    };

    plugin-promise-async = {
      url = "github:kevinhwang91/promise-async";
      flake = false;
    };

    plugin-nvim-ufo = {
      url = "github:kevinhwang91/nvim-ufo";
      flake = false;
    };

    plugin-new-file-template-nvim = {
      # (required by new-file-template.nvim)
      url = "github:otavioschwanck/new-file-template.nvim";
      flake = false;
    };

    plugin-haskell-tools-nvim = {
      url = "github:mrcjkb/haskell-tools.nvim";
      flake = false;
    };

    plugin-aerial-nvim = {
      url = "github:stevearc/aerial.nvim";
      flake = false;
    };
  };
}
