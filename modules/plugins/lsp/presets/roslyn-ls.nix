{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.lsp.presets.roslyn-ls;
in {
  options.vim.lsp.presets.roslyn-ls = {
    enable = mkLspPresetEnableOption "roslyn-ls" "Roslyn" [];
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.roslyn-ls = {
      cmd = mkLuaInline ''
        {
          '${getExe pkgs.roslyn-ls}',
          '--logLevel',
          'Information',
          '--extensionLogDirectory',
          vim.fs.joinpath(vim.uv.os_tmpdir(), 'roslyn_ls/logs'),
          '--stdio',
        }
      '';
      cmd_env = mkLuaInline ''
        {
          -- Fixes LSP navigation in decompiled files for systems with symlinked TMPDIR (macOS)
          TMPDIR = vim.env.TMPDIR and vim.env.TMPDIR ~= "" and vim.fn.resolve(vim.env.TMPDIR) or nil,
        }
      '';
      handlers = {
        "workspace/projectInitializationComplete" = mkLuaInline ''
          function(_, _, ctx)
              vim.notify('Roslyn project initialization complete', vim.log.levels.INFO, { title = 'roslyn_ls' })
              local client = assert(vim.lsp.get_client_by_id(ctx.client_id))

              local function refresh_diagnostics(client)
                for buf, _ in pairs(vim.lsp.get_client_by_id(client.id).attached_buffers) do
                  if vim.api.nvim_buf_is_loaded(buf) then
                    client:request(
                      vim.lsp.protocol.Methods.textDocument_diagnostic,
                      { textDocument = vim.lsp.util.make_text_document_params(buf) },
                      nil,
                      buf
                    )
                  end
                end
              end

              refresh_diagnostics(client)
              return vim.NIL
            end
        '';
        "workspace/_roslyn_projectNeedsRestore" = mkLuaInline ''
          function(_, result, ctx)
            local client = assert(vim.lsp.get_client_by_id(ctx.client_id))

            ---@diagnostic disable-next-line: param-type-mismatch
            client:request('workspace/_roslyn_restore', result, function(err, response)
              if err then
                vim.notify(err.message, vim.log.levels.ERROR, { title = 'roslyn_ls' })
              end
              if response then
                for _, v in ipairs(response) do
                  vim.notify(v.message, vim.log.levels.INFO, { title = 'roslyn_ls' })
                end
              end
            end)

            return vim.NIL
          end
        '';
        "razor/provideDynamicFileInfo" = mkLuaInline ''
          function(_, _, _)
            vim.notify(
              'Razor is not supported.\nPlease use https://github.com/tris203/rzls.nvim',
              vim.log.levels.WARN,
              { title = 'roslyn_ls' }
            )
            return vim.NIL
          end
        '';
      };
      commands = {
        "roslyn.client.completionComplexEdit" = mkLuaInline ''
          function(command, ctx)
            local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
            local args = command.arguments or {}
            local uri, edit = args[1], args[2]

            ---@diagnostic disable: undefined-field
            if uri and edit and edit.newText and edit.range then
              local workspace_edit = {
                changes = {
                  [uri.uri] = {
                    {
                      range = edit.range,
                      newText = edit.newText,
                    },
                  },
                },
              }
              vim.lsp.util.apply_workspace_edit(workspace_edit, client.offset_encoding)
            ---@diagnostic enable: undefined-field
            else
              vim.notify('roslyn_ls: completionComplexEdit args not understood: ' .. vim.inspect(args), vim.log.levels.WARN)
            end
          end
        '';

        "roslyn.client.nestedCodeAction" = mkLuaInline ''
          function(command, ctx)
            local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
            local arg = command.arguments and command.arguments[1]

            if type(arg) ~= 'table' then
              vim.notify('roslyn_ls: invalid nestedCodeAction arguments', vim.log.levels.ERROR)
              return
            end

            local function handle(action)
              if not action then
                return
              end

              if action.data and not action.edit and not action.command then
                client:request('codeAction/resolve', action, function(err, resolved)
                  if err then
                    vim.notify(err.message or tostring(err), vim.log.levels.ERROR)
                    return
                  end
                  if resolved then
                    handle(resolved)
                  end
                end, ctx.bufnr)
                return
              end

              local nested = vim.islist(action) and action or action.NestedCodeActions
              if type(nested) ~= 'table' or vim.tbl_isempty(nested) then
                local function apply_action(client, action)
                  if action.edit then
                    vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
                  end
                  if action.command then
                    client:exec_cmd(action.command)
                  end
                end
                apply_action(client, action)
                return
              end

              if #nested == 1 then
                handle(nested[1])
                return
              end

              vim.ui.select(nested, {
                prompt = action.title or 'Select code action',
                format_item = function(item)
                  return item.title or (item.command and item.command.title) or 'Unnamed action'
                end,
              }, function(choice)
                if choice then
                  handle(choice)
                end
              end)
            end

            handle(arg)
          end
        '';

        "roslyn.client.fixAllCodeAction" = mkLuaInline ''
          function(command, ctx)
            local client = assert(vim.lsp.get_client_by_id(ctx.client_id))

            local function handle_fix_all_action(client, command, bufnr)
              local arg = command.arguments and command.arguments[1]
              if type(arg) ~= 'table' then
                vim.notify('roslyn_ls: invalid fixAllCodeAction arguments', vim.log.levels.ERROR)
                return
              end

              local flavors = arg.FixAllFlavors
              if type(flavors) ~= 'table' or vim.tbl_isempty(flavors) then
                vim.notify('roslyn_ls: fixAllCodeAction has no FixAllFlavors', vim.log.levels.WARN)
                return
              end

              vim.ui.select(flavors, {
                prompt = 'Fix All Scope:',
              }, function(chosen_scope)
                if not chosen_scope then
                  return
                end

                client:request('codeAction/resolveFixAll', {
                  title = command.title,
                  data = arg,
                  scope = chosen_scope,
                }, function(err, resolved)
                  if err then
                    vim.notify(
                      'roslyn_ls: fixAllCodeAction resolve error: ' .. (err.message or tostring(err)),
                      vim.log.levels.ERROR
                    )
                    return
                  end
                  if resolved then
                    local function apply_action(client, action)
                      if action.edit then
                        vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
                      end
                      if action.command then
                        client:exec_cmd(action.command)
                      end
                    end
                    apply_action(client, resolved)
                  end
                end, bufnr)
              end)
            end

            handle_fix_all_action(client, command, ctx.bufnr)
          end
        '';
      };
      root_dir = mkLuaInline ''
        function(bufnr, cb)
            local bufname = vim.api.nvim_buf_get_name(bufnr)

            local function is_decompiled(bufname)
              local _, endpos = bufname:find('[/\\]MetadataAsSource[/\\]')
              if endpos == nil then
                return false
              end
              return vim.fn.finddir(bufname:sub(1, endpos), vim.uv.os_tmpdir()) ~= ""
            end

            -- don't try to find sln or csproj for files from libraries
            -- outside of the project
            if not is_decompiled(bufname) then
              -- try find solutions root first
              local root_dir = vim.fs.root(bufnr, function(fname, _)
                return fname:match('%.sln[x]?$') ~= nil
              end)

              if not root_dir then
                -- try find projects root
                root_dir = vim.fs.root(bufnr, function(fname, _)
                  return fname:match('%.csproj$') ~= nil
                end)
              end

              if root_dir then
                cb(root_dir)
              end
            else
              -- Decompiled code (example: "/tmp/MetadataAsSource/f2bfba/DecompilationMetadataAsSourceFileProvider/d5782a/Console.cs")
              local prev_buf = vim.fn.bufnr('#')
              local client = vim.lsp.get_clients({
                name = 'roslyn_ls',
                bufnr = prev_buf ~= 1 and prev_buf or nil,
              })[1]
              if client then
                cb(client.config.root_dir)
              end
            end
          end
      '';
      on_init = [
        (mkLuaInline
          ''
            function(client)
              local root_dir = client.config.root_dir

              local function on_init_sln(client, target)
                vim.notify('Initializing: ' .. target, vim.log.levels.TRACE, { title = 'roslyn_ls' })
                ---@diagnostic disable-next-line: param-type-mismatch
                client:notify('solution/open', {
                  solution = vim.uri_from_fname(target),
                })
              end


              local function on_init_project(client, project_files)
                vim.notify('Initializing: projects', vim.log.levels.TRACE, { title = 'roslyn_ls' })
                ---@diagnostic disable-next-line: param-type-mismatch
                client:notify('project/open', {
                  projects = vim.tbl_map(function(file)
                    return vim.uri_from_fname(file)
                  end, project_files),
                })
              end

              -- try load first solution we find
              for entry, type in vim.fs.dir(root_dir) do
                if type == 'file' and (vim.endswith(entry, '.sln') or vim.endswith(entry, '.slnx')) then
                  on_init_sln(client, vim.fs.joinpath(root_dir, entry))
                  return
                end
              end

              -- if no solution is found load project
              for entry, type in vim.fs.dir(root_dir) do
                if type == 'file' and vim.endswith(entry, '.csproj') then
                  on_init_project(client, { vim.fs.joinpath(root_dir, entry) })
                end
              end
            end
          '')
      ];
      on_attach = mkLuaInline ''
        function(client, bufnr)
            -- avoid duplicate autocmds for same buffer
            if vim.api.nvim_get_autocmds({ buffer = bufnr, group = group })[1] then
              return
            end

            local function refresh_diagnostics(client)
              for buf, _ in pairs(vim.lsp.get_client_by_id(client.id).attached_buffers) do
                if vim.api.nvim_buf_is_loaded(buf) then
                  client:request(
                    vim.lsp.protocol.Methods.textDocument_diagnostic,
                    { textDocument = vim.lsp.util.make_text_document_params(buf) },
                    nil,
                    buf
                  )
                end
              end
            end

            vim.api.nvim_create_autocmd({ 'BufWritePost', 'InsertLeave' }, {
              group = group,
              buffer = bufnr,
              callback = function()
                local function refresh_diagnostics(client)
                  for buf, _ in pairs(vim.lsp.get_client_by_id(client.id).attached_buffers) do
                    if vim.api.nvim_buf_is_loaded(buf) then
                      client:request(
                        vim.lsp.protocol.Methods.textDocument_diagnostic,
                        { textDocument = vim.lsp.util.make_text_document_params(buf) },
                        nil,
                        buf
                      )
                    end
                  end
                end
                refresh_diagnostics(client)
              end,
              desc = 'roslyn_ls: refresh diagnostics',
            })
          end
      '';
      capabilities = {
        # HACK: Doesn't show any diagnostics if we do not set this to true
        textDocument = {
          diagnostic = {
            dynamicRegistration = true;
          };
        };
      };
      settings = {
        "csharp|background_analysis" = {
          dotnet_analyzer_diagnostics_scope = "fullSolution";
          dotnet_compiler_diagnostics_scope = "fullSolution";
        };
        "csharp|inlay_hints" = {
          csharp_enable_inlay_hints_for_implicit_object_creation = true;
          csharp_enable_inlay_hints_for_implicit_variable_types = true;
          csharp_enable_inlay_hints_for_lambda_parameter_types = true;
          csharp_enable_inlay_hints_for_types = true;
          dotnet_enable_inlay_hints_for_indexer_parameters = true;
          dotnet_enable_inlay_hints_for_literal_parameters = true;
          dotnet_enable_inlay_hints_for_object_creation_parameters = true;
          dotnet_enable_inlay_hints_for_other_parameters = true;
          dotnet_enable_inlay_hints_for_parameters = true;
          dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true;
          dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true;
          dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true;
        };
        "csharp|symbol_search" = {
          dotnet_search_reference_assemblies = true;
        };
        "csharp|completion" = {
          dotnet_show_name_completion_suggestions = true;
          dotnet_show_completion_items_from_unimported_namespaces = true;
          dotnet_provide_regex_completions = true;
        };
        "csharp|code_lens" = {
          dotnet_enable_references_code_lens = true;
        };
      };
    };
  };
}
