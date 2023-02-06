{
  description = "A neovim flake with a modular configuration";
  outputs = {
    nixpkgs,
    flake-utils,
    ...
  } @ inputs: let
    modulesWithInputs = import ./modules {inherit inputs;};

    neovimConfiguration = {
      modules ? [],
      pkgs,
      lib ? pkgs.lib,
      check ? true,
      extraSpecialArgs ? {},
    }:
      modulesWithInputs {
        inherit pkgs lib check extraSpecialArgs;
        configuration = {...}: {
          imports = modules;
        };
      };

    nvimBin = pkg: "${pkg}/bin/nvim";

    buildPkg = pkgs: modules:
      (neovimConfiguration {
        inherit pkgs modules;
      })
      .neovim;

    tidalConfig = {
      config = {
        vim.tidal.enable = true;
      };
    };

    mainConfig = isMaximal: {
      config = {
        vim = {
          viAlias = true;
          vimAlias = true;
        };

        vim.lsp = {
          enable = true;
          formatOnSave = true;
          lightbulb.enable = true;
          lspsaga.enable = false;
          nvimCodeActionMenu.enable = true;
          trouble.enable = true;
          lspSignature.enable = true;
          rust.enable = isMaximal;
          python = isMaximal;
          clang.enable = isMaximal;
          sql = isMaximal;
          ts = isMaximal;
          go = isMaximal;
          zig.enable = isMaximal;
          nix = {
            enable = true;
            formatter = "alejandra";
          };
        };

        vim.visuals = {
          enable = true;
          nvimWebDevicons.enable = true;
          scrollBar.enable = true;
          smoothScroll.enable = true;
          cellularAutomaton.enable = true;
          lspkind.enable = true;
          indentBlankline = {
            enable = true;
            fillChar = "";
            eolChar = "";
            showCurrContext = true;
          };
          cursorWordline = {
            enable = true;
            lineTimeout = 0;
          };
        };

        vim.statusline.lualine = {
          enable = true;
          theme = "catppuccin";
        };

        vim.theme = {
          enable = true;
          name = "catppuccin";
          style = "mocha";
        };
        vim.autopairs.enable = true;

        vim.autocomplete = {
          enable = true;
          type = "nvim-cmp";
        };

        vim.filetree = {
          nvimTreeLua = {
            enable = true;
            view = {
              width = 25;
            };
          };
        };

        vim.tabline = {
          nvimBufferline.enable = true;
        };

        vim.treesitter = {
          enable = true;
          context.enable = true;
        };

        vim.binds = {
          whichKey.enable = true;
          cheatsheet.enable = true;
        };

        vim.telescope = {
          enable = true;
        };

        vim.markdown = {
          enable = true;
          glow.enable = true;
        };

        vim.git = {
          enable = true;
          gitsigns.enable = true;
        };

        vim.minimap = {
          minimap-vim.enable = false;
          codewindow.enable = true; # lighter, faster, and uses lua for configuration
        };

        vim.dashboard = {
          dashboard-nvim.enable = false;
          alpha.enable = true;
        };

        vim.notify = {
          nvim-notify.enable = true;
        };

        vim.utility = {
          colorizer.enable = true;
          icon-picker.enable = true;
          venn-nvim.enable = false; # FIXME throws an error when its commands are ran manually
        };

        vim.notes = {
          obsidian.enable = false; # FIXME neovim fails to build if obsidian is enabled
          orgmode.enable = true;
        };

        vim.terminal = {
          toggleterm.enable = true;
        };

        vim.ui = {
          noice.enable = true;
        };

        vim.assistant = {
          copilot.enable = false;
          tabnine.enable = false; # FIXME: this is not working because the plugin depends on an internal script to be ran by the package manager
        };

        vim.session = {
          nvim-session-manager.enable = false;
        };

        vim.gestures = {
          gesture-nvim.enable = false;
        };
      };
    };

    nixConfig = mainConfig false;
    maximalConfig = mainConfig true;
  in
    {
      lib = {
        nvim = (import ./lib/stdlib-extended.nix nixpkgs.lib).nvim;
        inherit neovimConfiguration;
      };

      overlays.default = final: prev: {
        inherit neovimConfiguration;
        neovim-nix = buildPkg prev [nixConfig];
        neovim-maximal = buildPkg prev [maximalConfig];
        neovim-tidal = buildPkg prev [tidalConfig];
      };
    }
    // (flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            inputs.tidalcycles.overlays.default
            (final: prev: {
              rnix-lsp = inputs.rnix-lsp.defaultPackage.${system};
              nil = inputs.nil.packages.${system}.default;
            })
          ];
        };

        docs = import ./docs {
          inherit pkgs;
          nmdSrc = inputs.nmd;
        };

        # Available Configurations
        tidalPkg = buildPkg pkgs [tidalConfig];
        nixPkg = buildPkg pkgs [nixConfig];
        maximalPkg = buildPkg pkgs [maximalConfig];
      in {
        apps =
          rec {
            nix = {
              type = "app";
              program = nvimBin nixPkg;
            };
            maximal = {
              type = "app";
              program = nvimBin maximalPkg;
            };
            default = nix;
          }
          // (
            if !(builtins.elem system ["aarch64-darwin" "x86_64-darwin"])
            then {
              tidal = {
                type = "app";
                program = nvimBin tidalPkg;
              };
            }
            else {}
          );

        devShells.default = pkgs.mkShell {nativeBuildInputs = [nixPkg];};

        packages =
          {
            # Documentation
            docs = docs.manual.html;
            docs-html = docs.manual.html;
            docs-manpages = docs.manPages;
            docs-json = docs.options.json;

            # Available Configurations
            default = nixPkg;
            nix = nixPkg;
            maximal = maximalPkg;
          }
          // (
            if !(builtins.elem system ["aarch64-darwin" "x86_64-darwin"])
            then {
              tidal = tidalPkg;
            }
            else {}
          );

        nixosModules.hm-module = {
          imports = [
            ./lib/hm.nix
            # {nixpkgs.overlays = [inputs.self.overlays.default];} what?
          ];
        };
      }
    ));

  # Flake inputs
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    # For generating documentation website
    nmd = {
      url = "gitlab:rycee/nmd";
      flake = false;
    };

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
      url = "github:lewis6991/nvim-treesitter-context";
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
    null-ls = {
      url = "github:jose-elias-alvarez/null-ls.nvim";
      flake = false;
    };
    sqls-nvim = {
      url = "github:nanotee/sqls.nvim";
      flake = false;
    };
    rust-tools = {
      url = "github:simrat39/rust-tools.nvim";
      flake = false;
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

    # Filetrees
    nvim-tree-lua = {
      url = "github:nvim-tree/nvim-tree.lua";
      flake = false;
    };

    # Tablines
    nvim-bufferline-lua = {
      url = "github:akinsho/nvim-bufferline.lua?ref=v3.0.1";
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
    discord-nvim = {
      url = "github:andweeb/presence.nvim";
      flake = false;
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

    # Rust crates
    crates-nvim = {
      url = "github:Saecki/crates.nvim";
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
      url = "github:kyazdani42/nvim-web-devicons";
      flake = false;
    };
    gitsigns-nvim = {
      url = "github:lewis6991/gitsigns.nvim";
      flake = false;
    };

    # Markdown
    glow-nvim = {
      url = "github:ellisonleao/glow.nvim";
      flake = false;
    };

    # Tidal cycles
    tidalcycles = {
      url = "github:mitchmindtree/tidalcycles.nix";
      inputs.vim-tidal-src.url = "github:tidalcycles/vim-tidal";
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
    colorizer = {
      url = "github:uga-rosa/ccc.nvim";
      flake = false;
    };

    venn-nvim = {
      url = "github:jbyuki/venn.nvim";
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

    # Note-taking

    obsidian-nvim = {
      url = "github:epwalsh/obsidian.nvim";
      flake = false;
    };

    orgmode-nvim = {
      url = "github:nvim-orgmode/orgmode";
      flake = false;
    };

    # Terminal
    toggleterm-nvim = {
      url = "github:akinsho/toggleterm.nvim";
      flake = false;
    };

    # UI
    noice-nvim = {
      url = "github:folke/noice.nvim";
      flake = false;
    };

    # Assistant
    copilot-lua = {
      url = "github:zbirenbaum/copilot.lua";
      flake = false;
    };

    tabnine-nvim = {
      url = "github:codota/tabnine-nvim";
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
  };
}
