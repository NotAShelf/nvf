{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) bool enum package;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.nvim.types) mkGrammarOption singleOrListOf;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.dag) entryAfter;

  cfg = config.vim.languages.clang;

  defaultServers = ["clangd"];
  servers = {
    ccls = {
      cmd = [(getExe pkgs.ccls)];
      filetypes = ["c" "cpp" "objc" "objcpp" "cuda"];
      offset_encoding = "utf-32";
      root_markers = ["compile_commands.json" ".ccls" ".git"];
      workspace_required = true;
      on_attach = mkLuaInline ''
        function(client, bufnr)
          local function switch_source_header(bufnr)
            local method_name = "textDocument/switchSourceHeader"
            local params = vim.lsp.util.make_text_document_params(bufnr)
            client:request(method_name, params, function(err, result)
              if err then
                error(tostring(err))
              end
              if not result then
                vim.notify('corresponding file cannot be determined')
                return
              end
              vim.cmd.edit(vim.uri_to_fname(result))
            end, bufnr)
          end

          vim.api.nvim_buf_create_user_command(
            bufnr,
            "LspCclsSwitchSourceHeader",
            function(arg)
              switch_source_header(client, 0)
            end,
            {desc = "Switch between source/header"}
          )
        end
      '';
    };

    clangd = {
      cmd = ["${pkgs.clang-tools}/bin/clangd"];
      filetypes = ["c" "cpp" "objc" "objcpp" "cuda" "proto"];
      root_markers = [
        ".clangd"
        ".clang-tidy"
        ".clang-format"
        "compile_commands.json"
        "compile_flags.txt"
        "configure.ac"
        ".git"
      ];
      capabilities = {
        textDocument = {
          completion = {
            editsNearCursor = true;
          };
        };
        offsetEncoding = ["utf-8" "utf-16"];
      };
      on_attach = mkLuaInline ''
        function(client, bufnr)
          local function switch_source_header(bufnr)
            local method_name = "textDocument/switchSourceHeader"
            local client = vim.lsp.get_clients({ bufnr = bufnr, name = "clangd", })[1]
            if not client then
              return vim.notify(('method %s is not supported by any servers active on the current buffer'):format(method_name))
            end
            local params = vim.lsp.util.make_text_document_params(bufnr)
            client.request(method_name, params, function(err, result)
              if err then
                error(tostring(err))
              end
              if not result then
                vim.notify('corresponding file cannot be determined')
                return
              end
              vim.cmd.edit(vim.uri_to_fname(result))
            end, bufnr)
          end

          local function symbol_info()
            local bufnr = vim.api.nvim_get_current_buf()
            local clangd_client = vim.lsp.get_clients({ bufnr = bufnr, name = "clangd" })[1]
            if not clangd_client or not clangd_client.supports_method 'textDocument/symbolInfo' then
              return vim.notify('Clangd client not found', vim.log.levels.ERROR)
            end
            local win = vim.api.nvim_get_current_win()
            local params = vim.lsp.util.make_position_params(win, clangd_client.offset_encoding)
            clangd_client:request('textDocument/symbolInfo', params, function(err, res)
              if err or #res == 0 then
                -- Clangd always returns an error, there is not reason to parse it
                return
              end
              local container = string.format('container: %s', res[1].containerName) ---@type string
              local name = string.format('name: %s', res[1].name) ---@type string
              vim.lsp.util.open_floating_preview({ name, container }, "", {
                height = 2,
                width = math.max(string.len(name), string.len(container)),
                focusable = false,
                focus = false,
                border = 'single',
                title = 'Symbol Info',
              })
            end, bufnr)
          end

          vim.api.nvim_buf_create_user_command(
            bufnr,
            "ClangdSwitchSourceHeader",
            function(arg)
              switch_source_header(0)
            end,
            {desc = "Switch between source/header"}
          )

          vim.api.nvim_buf_create_user_command(
            bufnr,
            "ClangdShowSymbolInfo",
            function(arg)
              symbol_info()
            end,
            {desc = "Show symbol info"}
          )
        end
      '';
    };
  };

  defaultDebugger = "lldb-vscode";
  debuggers = {
    lldb-vscode = {
      package = pkgs.lldb;
      dapConfig = ''
        dap.adapters.lldb = {
          type = 'executable',
          command = '${cfg.dap.package}/bin/lldb-dap',
          name = 'lldb'
        }
        dap.configurations.cpp = {
          {
            name = 'Launch',
            type = 'lldb',
            request = 'launch',
            program = function()
              return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
            end,
            cwd = "''${workspaceFolder}",
            stopOnEntry = false,
            args = {},
          },
        }

        dap.configurations.c = dap.configurations.cpp
      '';
    };
  };
in {
  options.vim.languages.clang = {
    enable = mkEnableOption "C/C++ language support";

    cHeader = mkOption {
      description = ''
        C syntax for headers. Can fix treesitter errors, see:
        https://www.reddit.com/r/neovim/comments/orfpcd/question_does_the_c_parser_from_nvimtreesitter/
      '';
      type = bool;
      default = false;
    };

    treesitter = {
      enable = mkEnableOption "C/C++ treesitter" // {default = config.vim.languages.enableTreesitter;};
      cPackage = mkGrammarOption pkgs "c";
      cppPackage = mkGrammarOption pkgs "cpp";
    };

    lsp = {
      enable = mkEnableOption "clang LSP support" // {default = config.vim.lsp.enable;};

      servers = mkOption {
        description = "The clang LSP server to use";
        type = singleOrListOf (enum (attrNames servers));
        default = defaultServers;
      };
    };

    dap = {
      enable = mkOption {
        description = "Enable clang Debug Adapter";
        type = bool;
        default = config.vim.languages.enableDAP;
      };
      debugger = mkOption {
        description = "clang debugger to use";
        type = enum (attrNames debuggers);
        default = defaultDebugger;
      };
      package = mkOption {
        description = "clang debugger package.";
        type = package;
        default = debuggers.${cfg.dap.debugger}.package;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.cHeader {
      vim.pluginRC.c-header = entryAfter ["basic"] "vim.g.c_syntax_for_h = 1";
    })

    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.cPackage cfg.treesitter.cppPackage];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.servers =
        mapListToAttrs (name: {
          inherit name;
          value = servers.${name};
        })
        cfg.lsp.servers;
    })

    (mkIf cfg.dap.enable {
      vim.debugger.nvim-dap.enable = true;
      vim.debugger.nvim-dap.sources.clang-debugger = debuggers.${cfg.dap.debugger}.dapConfig;
    })
  ]);
}
