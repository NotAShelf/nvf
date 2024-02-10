{
  description = "A neovim flake with a modular configuration";
  outputs = {
    nixpkgs,
    flake-parts,
    self,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      # provide overridable systems
      # https://github.com/nix-systems/nix-systems
      systems = import inputs.systems;

      imports = [
        # add lib to module args
        {_module.args = {inherit (nixpkgs) lib;};}
        ./flake/apps.nix
        ./flake/legacyPackages.nix
        ./flake/overlays.nix
        ./flake/packages.nix
      ];

      flake = {
        lib = {
          inherit (import ./lib/stdlib-extended.nix nixpkgs.lib) nvim;
          inherit (import ./configuration.nix inputs) neovimConfiguration;
        };

        homeManagerModules = {
          neovim-flake = {
            imports = [
              (import ./lib/module self.packages inputs)
            ];
          };

          default = self.homeManagerModules.neovim-flake;
        };
      };

      perSystem = {
        self',
        config,
        pkgs,
        ...
      }: {
        formatter = pkgs.alejandra;
        devShells = {
          default = self'.devShells.lsp;
          nvim-nix = pkgs.mkShell {nativeBuildInputs = [config.packages.nix];};
          lsp = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [nil statix deadnix];
          };
        };
      };
    };

  # Flake inputs
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-utils.url = "github:numtide/flake-utils";
    systems.url = "github:nix-systems/default";

    # For generating documentation website
    nmd = {
      url = "sourcehut:~rycee/nmd";
      flake = false;
    };

    # TODO: get zig from the zig overlay instead of nixpkgs
    zig.url = "github:mitchellh/zig-overlay";

    # LSP plugins
    nvim-lspconfig = {
      # url = "github:neovim/nvim-lspconfig?ref=v0.1.3";
      # Use master for nil_ls
      url = "github:neovim/nvim-lspconfig";
      flake = false;
    };

    lspsaga = {
      url = "github:tami5/lspsaga.nvim";
      flake = false;
    };

    lspkind = {
      url = "github:onsails/lspkind-nvim";
      flake = false;
    };

    trouble = {
      url = "github:folke/trouble.nvim";
      flake = false;
    };

    nvim-treesitter-context = {
      url = "github:nvim-treesitter/nvim-treesitter-context";
      flake = false;
    };

    nvim-lightbulb = {
      url = "github:kosayoda/nvim-lightbulb";
      flake = false;
    };

    nvim-code-action-menu = {
      url = "github:weilbith/nvim-code-action-menu";
      flake = false;
    };

    lsp-signature = {
      url = "github:ray-x/lsp_signature.nvim";
      flake = false;
    };

    lsp-lines = {
      url = "sourcehut:~whynothugo/lsp_lines.nvim";
      flake = false;
    };

    none-ls = {
      url = "github:nvimtools/none-ls.nvim";
      flake = false;
    };

    nvim-docs-view = {
      url = "github:amrbashir/nvim-docs-view";
      flake = false;
    };

    # language support
    sqls-nvim = {
      url = "github:nanotee/sqls.nvim";
      flake = false;
    };

    rust-tools = {
      url = "github:simrat39/rust-tools.nvim";
      flake = false;
    };

    flutter-tools = {
      url = "github:akinsho/flutter-tools.nvim";
      flake = false;
    };

    neodev-nvim = {
      url = "github:folke/neodev.nvim";
      flake = false;
    };

    elixir-ls = {
      url = "github:elixir-lsp/elixir-ls";
      flake = false;
    };

    elixir-tools = {
      url = "github:elixir-tools/elixir-tools.nvim";
      flake = false;
    };

    glow-nvim = {
      url = "github:ellisonleao/glow.nvim";
      flake = false;
    };

    # Tidal cycles
    tidalcycles = {
      url = "github:mitchmindtree/tidalcycles.nix";
      inputs.vim-tidal-src.url = "github:tidalcycles/vim-tidal";
    };

    # Copying/Registers
    registers = {
      url = "github:tversteeg/registers.nvim";
      flake = false;
    };

    nvim-neoclip = {
      url = "github:AckslD/nvim-neoclip.lua";
      flake = false;
    };

    # Telescope
    telescope = {
      url = "github:nvim-telescope/telescope.nvim";
      flake = false;
    };

    # Langauge server (use master instead of nixpkgs)
    rnix-lsp.url = "github:nix-community/rnix-lsp";
    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    # Debuggers
    nvim-dap = {
      url = "github:mfussenegger/nvim-dap";
      flake = false;
    };

    nvim-dap-ui = {
      url = "github:rcarriga/nvim-dap-ui";
      flake = false;
    };

    # Filetrees
    nvim-tree-lua = {
      url = "github:nvim-tree/nvim-tree.lua";
      flake = false;
    };

    # Tablines
    nvim-bufferline-lua = {
      url = "github:akinsho/nvim-bufferline.lua";
      flake = false;
    };

    # Statuslines
    lualine = {
      url = "github:hoob3rt/lualine.nvim";
      flake = false;
    };

    # Autocompletes
    nvim-compe = {
      url = "github:hrsh7th/nvim-compe";
      flake = false;
    };

    nvim-cmp = {
      url = "github:hrsh7th/nvim-cmp";
      flake = false;
    };
    cmp-buffer = {
      url = "github:hrsh7th/cmp-buffer";
      flake = false;
    };
    cmp-nvim-lsp = {
      url = "github:hrsh7th/cmp-nvim-lsp";
      flake = false;
    };
    cmp-vsnip = {
      url = "github:hrsh7th/cmp-vsnip";
      flake = false;
    };
    cmp-path = {
      url = "github:hrsh7th/cmp-path";
      flake = false;
    };
    cmp-treesitter = {
      url = "github:ray-x/cmp-treesitter";
      flake = false;
    };

    # snippets
    vim-vsnip = {
      url = "github:hrsh7th/vim-vsnip";
      flake = false;
    };

    # Presence
    neocord = {
      url = "github:IogaMaster/neocord";
      flake = false; # uses flake-utils, avoid the flake
    };

    # Autopairs
    nvim-autopairs = {
      url = "github:windwp/nvim-autopairs";
      flake = false;
    };
    nvim-ts-autotag = {
      url = "github:windwp/nvim-ts-autotag";
      flake = false;
    };

    # Commenting
    kommentary = {
      url = "github:b3nj5m1n/kommentary";
      flake = false;
    };

    comment-nvim = {
      url = "github:numToStr/Comment.nvim";
      flake = false;
    };

    todo-comments = {
      url = "github:folke/todo-comments.nvim";
      flake = false;
    };

    # Buffer tools
    bufdelete-nvim = {
      url = "github:famiu/bufdelete.nvim";
      flake = false;
    };

    # Dashboard Utilities
    dashboard-nvim = {
      url = "github:glepnir/dashboard-nvim";
      flake = false;
    };

    alpha-nvim = {
      url = "github:goolord/alpha-nvim";
      flake = false;
    };

    vim-startify = {
      url = "github:mhinz/vim-startify";
      flake = false;
    };

    # Themes
    tokyonight = {
      url = "github:folke/tokyonight.nvim";
      flake = false;
    };

    onedark = {
      url = "github:navarasu/onedark.nvim";
      flake = false;
    };

    catppuccin = {
      url = "github:catppuccin/nvim";
      flake = false;
    };

    dracula = {
      url = "github:Mofiqul/dracula.nvim";
      flake = false;
    };

    oxocarbon = {
      url = "github:glyh/oxocarbon.nvim/lualine-support";
      flake = false;
    };

    gruvbox = {
      url = "github:ellisonleao/gruvbox.nvim";
      flake = false;
    };

    # Rust crates
    crates-nvim = {
      url = "github:Saecki/crates.nvim";
      flake = false;
    };

    # Project Management
    project-nvim = {
      url = "github:ahmedkhalf/project.nvim";
      flake = false;
    };

    # Visuals
    nvim-cursorline = {
      url = "github:yamatsum/nvim-cursorline";
      flake = false;
    };

    scrollbar-nvim = {
      url = "github:petertriho/nvim-scrollbar";
      flake = false;
    };

    cinnamon-nvim = {
      url = "github:declancm/cinnamon.nvim";
      flake = false;
    };

    cellular-automaton = {
      url = "github:Eandrju/cellular-automaton.nvim";
      flake = false;
    };

    indent-blankline = {
      url = "github:lukas-reineke/indent-blankline.nvim";
      flake = false;
    };
    nvim-web-devicons = {
      url = "github:nvim-tree/nvim-web-devicons";
      flake = false;
    };
    gitsigns-nvim = {
      url = "github:lewis6991/gitsigns.nvim";
      flake = false;
    };

    fidget-nvim = {
      url = "github:j-hui/fidget.nvim?ref=legacy";
      flake = false;
    };

    highlight-undo = {
      url = "github:tzachar/highlight-undo.nvim";
      flake = false;
    };

    # Minimap
    minimap-vim = {
      url = "github:wfxr/minimap.vim";
      flake = false;
    };

    codewindow-nvim = {
      url = "github:gorbit99/codewindow.nvim";
      flake = false;
    };

    # Notifications
    nvim-notify = {
      url = "github:rcarriga/nvim-notify";
      flake = false;
    };

    # Utilities
    ccc = {
      url = "github:uga-rosa/ccc.nvim";
      flake = false;
    };

    diffview-nvim = {
      url = "github:sindrets/diffview.nvim";
      flake = false;
    };

    icon-picker-nvim = {
      url = "github:ziontee113/icon-picker.nvim";
      flake = false;
    };

    which-key = {
      url = "github:folke/which-key.nvim";
      flake = false;
    };

    cheatsheet-nvim = {
      url = "github:sudormrfbin/cheatsheet.nvim";
      flake = false;
    };

    gesture-nvim = {
      url = "github:notomo/gesture.nvim";
      flake = false;
    };

    hop-nvim = {
      url = "github:phaazon/hop.nvim";
      flake = false;
    };

    leap-nvim = {
      url = "github:ggandor/leap.nvim";
      flake = false;
    };

    smartcolumn = {
      url = "github:m4xshen/smartcolumn.nvim";
      flake = false;
    };

    nvim-surround = {
      url = "github:kylechui/nvim-surround";
      flake = false;
    };

    # Note-taking
    obsidian-nvim = {
      url = "github:epwalsh/obsidian.nvim";
      flake = false;
    };

    orgmode-nvim = {
      url = "github:nvim-orgmode/orgmode";
      flake = false;
    };

    mind-nvim = {
      url = "github:phaazon/mind.nvim";
      flake = false;
    };

    # Spellchecking
    vim-dirtytalk = {
      url = "github:psliwka/vim-dirtytalk";
      flake = false;
    };

    # Terminal
    toggleterm-nvim = {
      url = "github:akinsho/toggleterm.nvim";
      flake = false;
    };

    # UI
    nvim-navbuddy = {
      url = "github:SmiteshP/nvim-navbuddy";
      flake = false;
    };

    nvim-navic = {
      url = "github:SmiteshP/nvim-navic";
      flake = false;
    };

    noice-nvim = {
      url = "github:folke/noice.nvim";
      flake = false;
    };

    modes-nvim = {
      url = "github:mvllow/modes.nvim";
      flake = false;
    };

    nvim-colorizer-lua = {
      url = "github:NvChad/nvim-colorizer.lua";
      flake = false;
    };

    vim-illuminate = {
      url = "github:RRethy/vim-illuminate";
      flake = false;
    };

    # Assistant
    copilot-lua = {
      url = "github:zbirenbaum/copilot.lua";
      flake = false;
    };

    copilot-cmp = {
      url = "github:zbirenbaum/copilot-cmp";
      flake = false;
    };

    # Session management
    nvim-session-manager = {
      url = "github:Shatur/neovim-session-manager";
      flake = false;
    };

    # Dependencies
    plenary-nvim = {
      # (required by crates-nvim)
      url = "github:nvim-lua/plenary.nvim";
      flake = false;
    };

    dressing-nvim = {
      # (required by icon-picker-nvim)
      url = "github:stevearc/dressing.nvim";
      flake = false;
    };

    vim-markdown = {
      # (required by obsidian-nvim)
      url = "github:preservim/vim-markdown";
      flake = false;
    };

    tabular = {
      # (required by vim-markdown)
      url = "github:godlygeek/tabular";
      flake = false;
    };

    nui-nvim = {
      # (required by noice.nvim)
      url = "github:MunifTanjim/nui.nvim";
      flake = false;
    };

    vim-repeat = {
      url = "github:tpope/vim-repeat";
      flake = false;
    };
  };
}
