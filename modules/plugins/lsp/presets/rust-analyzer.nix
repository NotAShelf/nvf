{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOptionWith;
  inherit (lib.nvim.dag) entryBefore;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.lsp.presets.rust-analyzer;
in {
  options.vim.lsp.presets.rust-analyzer = {
    enable = mkLspPresetEnableOptionWith {
      option = "rust-analyzer";
      display = "Rust Analyzer";
      fileTypes = [];
      description = ''Note: do not set `init_options` for this LS config, it will be automatically populated by the contents of settings["rust-analyzer"] per https://github.com/rust-lang/rust-analyzer/blob/eb5da56d839ae0a9e9f50774fa3eb78eb0964550/docs/dev/lsp-extensions.md?plain=1#L26'';
    };
  };

  config = mkIf cfg.enable {
    # Taken from https://github.com/neovim/nvim-lspconfig/blob/07dff35e7c95288861200b788ef32d6103f107f0/lsp/rust_analyzer.lua

    # This code provides utility for cargo workspace functionality, as it is not wired by default.
    vim.luaConfigRC.rust-analyzer = entryBefore ["lsp-servers"] ''
      local function rust_reload_workspace(bufnr)
        local clients = vim.lsp.get_clients { bufnr = bufnr, name = 'rust-analyzer' }
        for _, client in ipairs(clients) do
          vim.notify 'Reloading Cargo Workspace'
          ---@diagnostic disable-next-line:param-type-mismatch
          client:request('rust-analyzer/reloadWorkspace', nil, function(err)
            if err then
              error(tostring(err))
            end
            vim.notify 'Cargo workspace reloaded'
          end, 0)
        end
      end

      local function rust_user_sysroot_src()
        return vim.tbl_get(vim.lsp.config['rust-analyzer'], 'settings', 'rust-analyzer', 'cargo', 'sysrootSrc')
      end

      -- Determine location of sysroot for stdlib
      local function rust_default_sysroot_src()
        local sysroot = vim.tbl_get(vim.lsp.config['rust-analyzer'], 'settings', 'rust-analyzer', 'cargo', 'sysroot')
        if not sysroot then
          local rustc = os.getenv 'RUSTC' or 'rustc'
          local result = vim.system({ rustc, '--print', 'sysroot' }, { text = true }):wait()

          local stdout = result.stdout
          if result.code == 0 and stdout then
            if string.sub(stdout, #stdout) == '\n' then
              if #stdout > 1 then
                sysroot = string.sub(stdout, 1, #stdout - 1)
              else
                sysroot = '''
              end
            else
              sysroot = stdout
            end
          end
        end

        return sysroot and vim.fs.joinpath(sysroot, 'lib/rustlib/src/rust/library') or nil
      end

      -- Determine if a given file belongs to an external library or our own code.
      local function rust_is_library(fname)
        local user_home = vim.fs.normalize(vim.env.HOME)
        local cargo_home = os.getenv 'CARGO_HOME' or user_home .. '/.cargo'
        local registry = cargo_home .. '/registry/src'
        local git_registry = cargo_home .. '/git/checkouts'

        local rustup_home = os.getenv 'RUSTUP_HOME' or user_home .. '/.rustup'
        local toolchains = rustup_home .. '/toolchains'

        local sysroot_src = rust_user_sysroot_src() or rust_default_sysroot_src()

        for _, item in ipairs { toolchains, registry, git_registry, sysroot_src } do
          if item and vim.fs.relpath(item, fname) then
            local clients = vim.lsp.get_clients { name = 'rust-analyzer' }
            return #clients > 0 and clients[#clients].config.root_dir or nil
          end
        end
      end
    '';

    vim.lsp.servers.rust-analyzer = {
      enable = true;
      cmd = [(getExe pkgs.rust-analyzer)];

      on_attach = mkLuaInline ''
        function(client, bufnr)
          vim.api.nvim_buf_create_user_command(bufnr, 'LspCargoReload', function()
            rust_reload_workspace(bufnr)
          end, { desc = 'Reload current cargo workspace' })
        end
      '';

      # Sends init_params beforehand according to rust-analyzer spec.
      # See https://github.com/rust-lang/rust-analyzer/blob/eb5da56d839ae0a9e9f50774fa3eb78eb0964550/docs/dev/lsp-extensions.md?plain=1#L26
      before_init = mkLuaInline ''
        function(init_params, config)
          if config.settings and config.settings['rust-analyzer'] then
            init_params.initializationOptions = config.settings['rust-analyzer']
          end

          -- Allow for a single run of a program
          vim.lsp.commands['rust-analyzer.runSingle'] = function(command)
            local r = command.arguments[1]
            local cmd = { 'cargo', unpack(r.args.cargoArgs) }
            if r.args.executableArgs and #r.args.executableArgs > 0 then
              vim.list_extend(cmd, { '--', unpack(r.args.executableArgs) })
            end

            local proc = vim.system(cmd, { cwd = r.args.cwd, env = r.args.environment })

            local result = proc:wait()

            if result.code == 0 then
              vim.notify(result.stdout, vim.log.levels.INFO)
            else
              vim.notify(result.stderr, vim.log.levels.ERROR)
            end
          end
        end
      '';

      # eval root dir taking workspaces into consideration
      root_dir = mkLuaInline ''
        function(bufnr, on_dir)
          local fname = vim.api.nvim_buf_get_name(bufnr)
          local reused_dir = rust_is_library(fname)
          if reused_dir then
            on_dir(reused_dir)
            return
          end

          local cargo_crate_dir = vim.fs.root(fname, { 'Cargo.toml' })
          local cargo_workspace_root

          if cargo_crate_dir == nil then
            on_dir(
              vim.fs.root(fname, { 'rust-project.json' })
                or vim.fs.dirname(vim.fs.find('.git', { path = fname, upward = true })[1])
            )
            return
          end

          local cmd = {
            'cargo',
            'metadata',
            '--no-deps',
            '--format-version',
            '1',
            '--manifest-path',
            cargo_crate_dir .. '/Cargo.toml',
          }

          vim.system(cmd, { text = true }, function(output)
            if output.code == 0 then
              if output.stdout then
                local result = vim.json.decode(output.stdout)
                if result['workspace_root'] then
                  cargo_workspace_root = vim.fs.normalize(result['workspace_root'])
                end
              end

              on_dir(cargo_workspace_root or cargo_crate_dir)
            else
              vim.schedule(function()
                vim.notify(('[rust_analyzer] cmd failed with code %d: %s\n%s'):format(output.code, cmd, output.stderr))
              end)
            end
          end)
        end
      '';

      capabilities = {
        experimental = {
          serverStatusNotification = true;
          commands = {
            commands = [
              "rust-analyzer.showReferences"
              "rust-analyzer.runSingle"
              "rust-analyzer.debugSingle"
            ];
          };
        };
      };
    };
  };
}
