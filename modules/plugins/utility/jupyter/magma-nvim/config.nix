{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.binds) mkKeymap;

  cfg = config.vim.utility.jupyter.magma-nvim;
  opts = cfg.setupOpts;
  keys = cfg.mappings;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = ["magma-nvim"];
      withPython3 = true;
      python3Packages = ["pynvim" "jupyter-client" "ipykernel"] ++ cfg.python3Packages;

      pluginRC.magma-nvim = entryAnywhere ''
        vim.g.magma_automatically_open_output = ${toLuaObject opts.automaticallyOpenOutput}
        vim.g.magma_image_provider = ${toLuaObject opts.imageProvider}
        vim.g.magma_wrap_output = ${toLuaObject opts.wrapOutput}
        vim.g.magma_output_window_borders = ${toLuaObject opts.outputWindowBorders}
        vim.g.magma_cell_highlight_group = ${toLuaObject opts.cellHighlightGroup}
        ${lib.optionalString (opts.savePath != null) "vim.g.magma_save_path = ${toLuaObject opts.savePath}"}
        vim.g.magma_copy_output = ${toLuaObject opts.copyOutput}
        vim.g.magma_show_mimetype_debug = ${toLuaObject opts.showMimetypeDebug}

        vim.g.loaded_remote_plugins = mnw.configDir .. "/rplugin.vim"

        local magma_script = vim.api.nvim_get_runtime_file("rplugin/python3/magma", true)[1]
        if magma_script then
          vim.cmd([[
            call remote#host#RegisterPlugin('python3', ']] .. magma_script .. [[', [
              \ {'sync': v:true, 'name': 'MagmaDeinit', 'type': 'command', 'opts': {}},
              \ {'sync': v:true, 'name': 'MagmaDelete', 'type': 'command', 'opts': {}},
              \ {'sync': v:true, 'name': 'MagmaDeleteAll', 'type': 'command', 'opts': {}},
              \ {'sync': v:true, 'name': 'MagmaEnterOutput', 'type': 'command', 'opts': {}},
              \ {'sync': v:true, 'name': 'MagmaReevaluateCell', 'type': 'command', 'opts': {}},
              \ {'sync': v:true, 'name': 'MagmaEvaluateLine', 'type': 'command', 'opts': {}},
              \ {'sync': v:true, 'name': 'MagmaEvaluateOperator', 'type': 'command', 'opts': {}},
              \ {'sync': v:true, 'name': 'MagmaEvaluateVisual', 'type': 'command', 'opts': {}},
              \ {'sync': v:true, 'name': 'MagmaInit', 'type': 'command', 'opts': {'complete': 'file', 'nargs': '?'}},
              \ {'sync': v:true, 'name': 'MagmaInterrupt', 'type': 'command', 'opts': {}},
              \ {'sync': v:true, 'name': 'MagmaLoad', 'type': 'command', 'opts': {'nargs': '?'}},
              \ {'sync': v:true, 'name': 'MagmaRestart', 'type': 'command', 'opts': {'bang': ""}},
              \ {'sync': v:true, 'name': 'MagmaSave', 'type': 'command', 'opts': {'nargs': '?'}},
              \ {'sync': v:true, 'name': 'MagmaShowOutput', 'type': 'command', 'opts': {}},
              \ {'sync': v:true, 'name': 'MagmaEvaluateArgument', 'type': 'command', 'opts': {'nargs': 1}},
              \ {'sync': v:true, 'name': 'MagmaClearInterface', 'type': 'function', 'opts': {}},
              \ {'sync': v:true, 'name': 'MagmaDefineCell', 'type': 'function', 'opts': {}},
              \ {'sync': v:true, 'name': 'MagmaOperatorfunc', 'type': 'function', 'opts': {}},
              \ {'sync': v:true, 'name': 'MagmaTick', 'type': 'function', 'opts': {}},
              \ {'sync': v:true, 'name': 'MagmaOnBufferUnload', 'type': 'function', 'opts': {}},
              \ {'sync': v:true, 'name': 'MagmaOnExitPre', 'type': 'function', 'opts': {}},
              \ {'sync': v:true, 'name': 'MagmaUpdateInterface', 'type': 'function', 'opts': {}},
              \ ])
          ]])
        end

        local function magma_insert_cell(kind, above)
          local marker = kind == "markdown" and "# %% [markdown]" or "# %%"
          local line = vim.api.nvim_win_get_cursor(0)[1]
          if above then
            vim.api.nvim_buf_set_lines(0, line - 1, line - 1, false, { marker, "" })
            vim.api.nvim_win_set_cursor(0, { line + 1, 0 })
          else
            vim.api.nvim_buf_set_lines(0, line, line, false, { "", marker })
            vim.api.nvim_win_set_cursor(0, { line + 3, 0 })
          end
        end
        vim.g.magma_insert_cell = magma_insert_cell

        local function magma_run_cell()
          local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
          local cur = vim.api.nvim_win_get_cursor(0)[1] - 1
          local n = #lines
          local is_marker = function(l)
            return l ~= nil and (vim.startswith(l, "# %%") or vim.startswith(l, "#%%"))
          end
          local is_markdown = function(l)
            return l ~= nil and l:match("^#%s*%%+%s*%[markdown%]") ~= nil
          end
          local marker_row = nil
          local start = 0
          if is_marker(lines[cur + 1]) then
            marker_row = cur
            start = cur + 1
          else
            for r = cur - 1, 0, -1 do
              if is_marker(lines[r + 1]) then
                marker_row = r
                start = r + 1
                break
              end
            end
          end
          local endline = n - 1
          for r = cur + 1, n - 1 do
            if is_marker(lines[r + 1]) then
              endline = r - 1
              break
            end
          end
          while endline >= start and lines[endline + 1]:match("^%s*$") do
            endline = endline - 1
          end
          while start <= endline and lines[start + 1]:match("^%s*$") do
            start = start + 1
          end
          if marker_row ~= nil and is_markdown(lines[marker_row + 1]) then
            vim.notify("Magma: markdown cell, nothing to run", vim.log.levels.INFO)
            return
          end
          if endline < start then
            vim.notify("Magma: cell is empty", vim.log.levels.WARN)
            return
          end
          vim.fn.setpos("'<", { 0, start + 1, 1, 0 })
          vim.fn.setpos("'>", { 0, endline + 1, vim.fn.col("$"), 0 })
          vim.cmd("MagmaEvaluateVisual")
        end
        vim.g.magma_run_cell = magma_run_cell

        local function magma_register_kernel()
          local function venv_name(dir)
            local base = vim.fn.fnamemodify(dir, ":t")
            if base == ".venv" or base == "venv" then
              return vim.fn.fnamemodify(dir, ":h:t") .. "-" .. base
            end
            return base
          end

          local python = ""
          local name = ""
          local env = vim.fn.getenv("VIRTUAL_ENV")
          if env ~= vim.NIL and env ~= "" then
            python = env .. "/bin/python"
            name = venv_name(env)
          else
            env = vim.fn.getenv("CONDA_PREFIX")
            if env ~= vim.NIL and env ~= "" then
              python = env .. "/bin/python"
              name = vim.fn.fnamemodify(env, ":t")
            elseif vim.fn.getenv("IN_NIX_SHELL") ~= vim.NIL and vim.fn.getenv("IN_NIX_SHELL") ~= "" then
              python = vim.fn.exepath("python")
              name = "nix-shell"
            else
              python = vim.fn.exepath("python3")
              name = "system"
            end
          end
          if python == "" then
            python = vim.fn.exepath("python3")
            if python == "" then
              vim.notify("Magma: no Python interpreter found to register", vim.log.levels.ERROR)
              return
            end
          end

          if ${toLuaObject opts.preferNixVenvWrapper} then
            local nix_wrapper = vim.fn.fnamemodify(python, ":h") .. "/python3-nix"
            if vim.fn.filereadable(nix_wrapper) == 1 then
              python = nix_wrapper
            end
          end

          local check = vim.fn.system(python .. " -c 'import ipykernel' 2>&1")
          if vim.v.shell_error ~= 0 then
            local detail = vim.fn.trim(check)
            if detail == "" then
              detail = "ipykernel is missing (install it with `" .. python
                .. " -m pip install ipykernel`)"
            end
            vim.notify(
              "Magma: import ipykernel failed in " .. python .. ": " .. detail,
              vim.log.levels.ERROR
            )
            return
          end

          local data_dir = vim.fn.getenv("JUPYTER_DATA_DIR")
          if data_dir == vim.NIL or data_dir == "" then
            data_dir = vim.fn.expand("~/.local/share/jupyter")
          end
          local kernels_dir = data_dir .. "/kernels/" .. name
          vim.fn.mkdir(kernels_dir, "p")
          vim.fn.writefile({
            vim.json.encode({
              argv = { python, "-m", "ipykernel_launcher", "-f", "{connection_file}" },
              display_name = name,
              language = "python",
            }),
          }, kernels_dir .. "/kernel.json")

          vim.notify(
            "Magma: registered kernel '" .. name .. "' from " .. python
              .. ". Use <leader>mk or :MagmaInit to select it.",
            vim.log.levels.INFO
          )
        end
        vim.g.magma_register_kernel = magma_register_kernel
      '';

      keymaps = [
        (mkKeymap "n" keys.init "<cmd>MagmaInit ${opts.defaultKernel}<CR>" {desc = "Initialize kernel";})
        (mkKeymap "n" keys.deinit "<cmd>MagmaDeinit<CR>" {desc = "Deinitialize kernel";})
        (mkKeymap "n" keys.evaluateLine "<cmd>MagmaEvaluateLine<CR>" {desc = "Evaluate line";})
        (mkKeymap "n" keys.evaluateOperator "nvim_exec('MagmaEvaluateOperator', v:true)" {
          desc = "Evaluate operator";
          expr = true;
        })
        (mkKeymap "v" keys.evaluateVisual ":<C-u>MagmaEvaluateVisual<CR>" {desc = "Evaluate visual selection";})
        (mkKeymap "n" keys.reevaluateCell "<cmd>MagmaReevaluateCell<CR>" {desc = "Re-evaluate cell";})
        (mkKeymap "n" keys.delete "<cmd>MagmaDelete<CR>" {desc = "Delete cell";})
        (mkKeymap "n" keys.deleteAll "<cmd>MagmaDeleteAll<CR>" {desc = "Delete all cell outputs";})
        (mkKeymap "n" keys.showOutput "<cmd>MagmaShowOutput<CR>" {desc = "Show output";})
        (mkKeymap "n" keys.restart "<cmd>MagmaRestart!<CR>" {desc = "Restart kernel";})
        (mkKeymap "n" keys.interrupt "<cmd>MagmaInterrupt<CR>" {desc = "Interrupt execution";})
        (mkKeymap "n" keys.save "<cmd>MagmaSave<CR>" {desc = "Save cells";})
        (mkKeymap "n" keys.load "<cmd>MagmaLoad<CR>" {desc = "Load cells";})
        (mkKeymap "n" keys.enterOutput "<cmd>noautocmd MagmaEnterOutput<CR>" {desc = "Enter output window";})
        (mkKeymap "n" keys.runAll "ggVG<cmd>MagmaEvaluateVisual<CR>" {desc = "Evaluate entire buffer";})
        (mkKeymap "n" keys.runCell "<cmd>lua vim.g.magma_run_cell()<CR>" {desc = "Run cell under cursor";})
        (mkKeymap "n" keys.insertCodeCellBelow "<cmd>lua vim.g.magma_insert_cell('code', false)<CR>" {desc = "Insert code cell below";})
        (mkKeymap "n" keys.insertCodeCellAbove "<cmd>lua vim.g.magma_insert_cell('code', true)<CR>" {desc = "Insert code cell above";})
        (mkKeymap "n" keys.insertMarkdownCellBelow "<cmd>lua vim.g.magma_insert_cell('markdown', false)<CR>" {desc = "Insert markdown cell below";})
        (mkKeymap "n" keys.insertMarkdownCellAbove "<cmd>lua vim.g.magma_insert_cell('markdown', true)<CR>" {desc = "Insert markdown cell above";})
        (mkKeymap "n" keys.selectKernel "<cmd>MagmaInit<CR>" {desc = "Select Jupyter kernel";})
        (mkKeymap "n" keys.registerKernel "<cmd>lua vim.g.magma_register_kernel()<CR>" {desc = "Register current environment as kernel";})
      ];
    };
  };
}
