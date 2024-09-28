isMaximal: {
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
      trouble.enable = true;
      lspSignature.enable = true;
      otter-nvim.enable = isMaximal;
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

      # Nim LSP is broken on Darwin and therefore
      # should be disabled by default. Users may still enable
      # `vim.languages.vim` to enable it, this does not restrict
      # that.
      # See: <https://github.com/PMunch/nimlsp/issues/178#issue-2128106096>
      nim.enable = false;

      nix.enable = true;

      markdown.enable = isMaximal;
      html.enable = isMaximal;
      css.enable = isMaximal;
      sql.enable = isMaximal;
      java.enable = isMaximal;
      ts.enable = isMaximal;
      svelte.enable = isMaximal;
      go.enable = isMaximal;
      elixir.enable = isMaximal;
      zig.enable = isMaximal;
      ocaml.enable = isMaximal;
      python.enable = isMaximal;
      dart.enable = isMaximal;
      bash.enable = isMaximal;
      r.enable = isMaximal;
      tailwind.enable = isMaximal;
      typst.enable = isMaximal;
      clang = {
        enable = isMaximal;
        lsp.server = "clangd";
      };

      rust = {
        enable = isMaximal;
        crates.enable = isMaximal;
      };
    };

    visuals = {
      enable = true;
      nvimWebDevicons.enable = true;
      scrollBar.enable = isMaximal;
      smoothScroll.enable = true;
      cellularAutomaton.enable = false;
      fidget-nvim.enable = true;
      highlight-undo.enable = true;

      indentBlankline.enable = true;

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
      ccc.enable = false;
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
          nix = "110";
          ruby = "120";
          java = "130";
          go = ["90" "130"];
        };
      };
      fastaction.enable = true;
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
}
