inputs: let
  modulesWithInputs = import ./modules inputs;

  neovimConfiguration = {
    modules ? [],
    pkgs,
    lib ? pkgs.lib,
    check ? true,
    extraSpecialArgs ? {},
  }:
    modulesWithInputs {
      inherit pkgs lib check extraSpecialArgs;
      configuration.imports = modules;
    };

  mainConfig = isMaximal: {
    config = {
      vim = {
        viAlias = true;
        vimAlias = true;
        debugMode = {
          enable = true;
          level = 20;
          logFile = "/tmp/nvim.log";
        };
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
        fidget-nvim.enable = true;
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

      vim.statusline = {
        lualine = {
          enable = false;
          theme = "catppuccin";
        };
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
        orgmode.enable = false;
        mind-nvim.enable = true;
      };

      vim.terminal = {
        toggleterm.enable = true;
      };

      vim.ui = {
        noice.enable = true;
      };

      vim.assistant = {
        copilot.enable = isMaximal;
        #tabnine.enable = false; # FIXME: this is not working because the plugin depends on an internal script to be ran by the package manager
      };

      vim.session = {
        nvim-session-manager.enable = false;
      };

      vim.gestures = {
        gesture-nvim.enable = false;
      };

      vim.comments = {
        comment-nvim.enable = true;
        kommentary. enable = false;
      };

      vim.presence = {
        presence-nvim = {
          enable = true;
          auto_update = true;
          image_text = "The One True Text Editor";
          client_id = "793271441293967371";
          main_image = "neovim";
          rich_presence = {
            editing_text = "Editing %s";
          };
        };
      };
    };
  };
in {
  inherit neovimConfiguration mainConfig;
}
