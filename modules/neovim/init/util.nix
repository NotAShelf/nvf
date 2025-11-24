{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.dag) entryBefore;

  cfg = config.vim.lsp;
in {
  config = mkMerge [
    (mkIf (cfg.servers != {}) {
      vim.luaConfigRC.lsp-util =
        entryBefore ["lsp-servers"]
        /*
        lua
        */
        ''
          -- Port of nvim-lspconfig util
          local util = { path = {} }

          util.default_config = {
            log_level = vim.lsp.protocol.MessageType.Warning,
            message_level = vim.lsp.protocol.MessageType.Warning,
            settings = vim.empty_dict(),
            init_options = vim.empty_dict(),
            handlers = {},
            autostart = true,
            capabilities = vim.lsp.protocol.make_client_capabilities(),
          }

          -- global on_setup hook
          util.on_setup = nil

          do
            local validate = vim.validate
            local api = vim.api
            local lsp = vim.lsp
            local nvim_eleven = vim.fn.has 'nvim-0.11' == 1

            local iswin = vim.uv.os_uname().version:match 'Windows'

            local function escape_wildcards(path)
              return path:gsub('([%[%]%?%*])', '\\%1')
            end

            local function is_fs_root(path)
              if iswin then
                return path:match '^%a:$'
              else
                return path == '/'
              end
            end

            local function traverse_parents(path, cb)
              path = vim.uv.fs_realpath(path)
              local dir = path
              -- Just in case our algo is buggy, don't infinite loop.
              for _ = 1, 100 do
                dir = vim.fs.dirname(dir)
                if not dir then
                  return
                end
                -- If we can't ascend further, then stop looking.
                if cb(dir, path) then
                  return dir, path
                end
                if is_fs_root(dir) then
                  break
                end
              end
            end

            util.root_pattern = function(...)
              local patterns = util.tbl_flatten { ... }
              return function(startpath)
                startpath = util.strip_archive_subpath(startpath)
                for _, pattern in ipairs(patterns) do
                  local match = util.search_ancestors(startpath, function(path)
                    for _, p in ipairs(vim.fn.glob(table.concat({ escape_wildcards(path), pattern }, '/'), true, true)) do
                      if vim.uv.fs_stat(p) then
                        return path
                      end
                    end
                  end)

                  if match ~= nil then
                    return match
                  end
                end
              end
            end

            util.root_markers_with_field = function(root_files, new_names, field, fname)
              local path = vim.fn.fnamemodify(fname, ':h')
              local found = vim.fs.find(new_names, { path = path, upward = true })

              for _, f in ipairs(found or {}) do
                -- Match the given `field`.
                for line in io.lines(f) do
                  if line:find(field) then
                    root_files[#root_files + 1] = vim.fs.basename(f)
                    break
                  end
                end
              end

              return root_files
            end

            util.insert_package_json = function(root_files, field, fname)
              return util.root_markers_with_field(root_files, { 'package.json', 'package.json5' }, field, fname)
            end

            util.strip_archive_subpath = function(path)
              -- Matches regex from zip.vim / tar.vim
              path = vim.fn.substitute(path, 'zipfile://\\(.\\{-}\\)::[^\\\\].*$', '\\1', ''')
              path = vim.fn.substitute(path, 'tarfile:\\(.\\{-}\\)::.*$', '\\1', ''')
              return path
            end

            util.get_typescript_server_path = function(root_dir)
              local project_roots = vim.fs.find('node_modules', { path = root_dir, upward = true, limit = math.huge })
              for _, project_root in ipairs(project_roots) do
                local typescript_path = project_root .. '/typescript'
                local stat = vim.loop.fs_stat(typescript_path)
                if stat and stat.type == 'directory' then
                  return typescript_path .. '/lib'
                end
              end
              return '''
            end

            util.search_ancestors = function(startpath, func)
              if nvim_eleven then
                validate('func', func, 'function')
              end
              if func(startpath) then
                return startpath
              end
              local guard = 100
              for path in vim.fs.parents(startpath) do
                -- Prevent infinite recursion if our algorithm breaks
                guard = guard - 1
                if guard == 0 then
                  return
                end

                if func(path) then
                  return path
                end
              end
            end

            util.path.is_descendant = function(root, path)
              if not path then
                return false
              end

              local function cb(dir, _)
                return dir == root
              end

              local dir, _ = traverse_parents(path, cb)

              return dir == root
            end

            util.tbl_flatten = function(t)
              --- @diagnostic disable-next-line:deprecated
              return nvim_eleven and vim.iter(t):flatten(math.huge):totable() or vim.tbl_flatten(t)
            end
          end
        '';
    })
  ];
}
