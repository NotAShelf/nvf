inputs: let
  modulesWithInputs = import ./modules inputs;

  neovimConfiguration = {
    modules ? [],
    pkgs,
    lib ? pkgs.lib,
    check ? true,
    extraSpecialArgs ? {},
    extraModules ? [],
    ...
  }:
    modulesWithInputs {
      inherit pkgs lib check extraSpecialArgs extraModules;
      configuration.imports = modules;
    };

  mainConfig = isMaximal: {
    config.vim = {
      viAlias = true;
      vimAlias = true;
      debugMode = {
        enable = false;
        level = 16;
        logFile = "/tmp/nvim.log";
      };

      spellcheck = {
        enable = isMaximal;
      };

      lsp = {
        formatOnSave = true;
        lspkind.enable = false;
        lightbulb.enable = true;
        lspsaga.enable = false;
        nvimCodeActionMenu.enable = isMaximal;
        trouble.enable = true;
        lspSignature.enable = true;
        lsplines.enable = isMaximal;
        nvim-docs-view.enable = isMaximal;
      };

      debugger = {
        nvim-dap = {
          enable = true;
          ui.enable = true;
        };
      };

      languages = {
        enableLSP = true;
        enableFormat = true;
        enableTreesitter = true;
        enableExtraDiagnostics = true;

        nim.enable = false;
        elixir.enable = false;

        nix.enable = true;
        markdown.enable = true;

        html.enable = isMaximal;
        css.enable = isMaximal;
        sql.enable = isMaximal;
        java.enable = isMaximal;
        ts.enable = isMaximal;
        svelte.enable = isMaximal;
        go.enable = isMaximal;
        zig.enable = isMaximal;
        python.enable = isMaximal;
        dart.enable = isMaximal;
        bash.enable = isMaximal;
        tailwind.enable = isMaximal;
        typst.enable = isMaximal;
        clang = {
          enable = isMaximal;
          lsp.server = "clangd";
        };

        rust = {
          enable = isMaximal;
          crates.enable = true;
        };
      };

      visuals = {
        enable = true;
        nvimWebDevicons.enable = true;
        scrollBar.enable = true;
        smoothScroll.enable = true;
        cellularAutomaton.enable = false;
        fidget-nvim.enable = true;
        highlight-undo.enable = true;

        indentBlankline = {
          enable = true;
          fillChar = null;
          eolChar = null;
          scope = {
            enabled = true;
          };
        };

        cursorline = {
          enable = true;
          lineTimeout = 0;
        };
      };

      statusline = {
        lualine = {
          enable = true;
          theme = "catppuccin";
        };
      };

      theme = {
        enable = true;
        name = "catppuccin";
        style = "mocha";
        transparent = false;
      };

      autopairs.enable = true;

      autocomplete = {
        enable = true;
        type = "nvim-cmp";
      };

      filetree = {
        nvimTree = {
          enable = true;
        };
      };

      tabline = {
        nvimBufferline.enable = true;
      };

      treesitter.context.enable = true;

      binds = {
        whichKey.enable = true;
        cheatsheet.enable = true;
      };

      telescope.enable = true;

      git = {
        enable = true;
        gitsigns.enable = true;
        gitsigns.codeActions.enable = false; # throws an annoying debug message
      };

      minimap = {
        minimap-vim.enable = false;
        codewindow.enable = isMaximal; # lighter, faster, and uses lua for configuration
      };

      dashboard = {
        dashboard-nvim.enable = false;
        alpha.enable = isMaximal;
      };

      notify = {
        nvim-notify.enable = true;
      };

      projects = {
        project-nvim.enable = isMaximal;
      };

      utility = {
        ccc.enable = isMaximal;
        vim-wakatime.enable = false;
        icon-picker.enable = isMaximal;
        surround.enable = isMaximal;
        diffview-nvim.enable = true;
        motion = {
          hop.enable = true;
          leap.enable = true;
        };

        images = {
          image-nvim.enable = false;
        };
      };

      notes = {
        obsidian.enable = false; # FIXME: neovim fails to build if obsidian is enabled
        orgmode.enable = false;
        mind-nvim.enable = isMaximal;
        todo-comments.enable = true;
      };

      terminal = {
        toggleterm = {
          enable = true;
          lazygit.enable = true;
        };
      };

      ui = {
        borders.enable = true;
        noice.enable = true;
        colorizer.enable = true;
        modes-nvim.enable = false; # the theme looks terrible with catppuccin
        illuminate.enable = true;
        breadcrumbs = {
          enable = isMaximal;
          navbuddy.enable = isMaximal;
        };
        smartcolumn = {
          enable = true;
          setupOpts.custom_colorcolumn = {
            # this is a freeform module, it's `buftype = int;` for configuring column position
            nix = 110;
            ruby = 120;
            java = 130;
            go = [90 130];
          };
        };
      };

      assistant = {
        chatgpt.enable = false;
        copilot = {
          enable = false;
          cmp.enable = isMaximal;
        };
      };

      session = {
        nvim-session-manager.enable = false;
      };

      gestures = {
        gesture-nvim.enable = false;
      };

      comments = {
        comment-nvim.enable = true;
      };

      presence = {
        neocord.enable = false;
      };
    };
  };
in {
  inherit neovimConfiguration mainConfig;
}
