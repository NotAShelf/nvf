{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.meta) getExe;
  inherit (builtins) attrNames;
  inherit (lib.types) listOf enum;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.dag) entryBefore;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.languages.java;

  defaultServers = ["jdtls"];
  servers = {
    jdtls = {
      enable = true;
      cmd =
        mkLuaInline
        /*
        lua
        */
        ''
          {
            '${getExe pkgs.jdt-language-server}',
            '-configuration',
            get_jdtls_config_dir(),
            '-data',
            get_jdtls_workspace_dir(),
            get_jdtls_jvm_args(),
          }
        '';
      filetypes = ["java"];
      root_markers = [
        # Multi-module projects
        ".git"
        "build.gradle"
        "build.gradle.kts"
        # Single-module projects
        "build.xml" # Ant
        "pom.xml" # Maven
        "settings.gradle" # Gradle
        "settings.gradle.kts" # Gradle
      ];
      init_options = {
        workspace = mkLuaInline "get_jdtls_workspace_dir()";
        jvm_args = {};
        os_config = mkLuaInline "nil";
      };
      handlers = {
        "textDocument/codeAction" = mkLuaInline "jdtls_on_textdocument_codeaction";
        "textDocument/rename" = mkLuaInline "jdtls_on_textdocument_rename";
        "workspace/applyEdit" = mkLuaInline "jdtls_on_workspace_applyedit";
        "language/status" = mkLuaInline "vim.schedule_wrap(jdtls_on_language_status)";
      };
    };
  };
in {
  options.vim.languages.java = {
    enable = mkEnableOption "Java language support";

    treesitter = {
      enable = mkEnableOption "Java treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "java";
    };

    lsp = {
      enable = mkEnableOption "Java LSP support" // {default = config.vim.lsp.enable;};
      servers = mkOption {
        type = listOf (enum (attrNames servers));
        default = defaultServers;
        description = "Java LSP server to use";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.lsp.enable {
      vim.luaConfigRC.jdtls-util =
        entryBefore ["lsp-servers"]
        /*
        lua
        */
        ''
          local jdtls_handlers = require 'vim.lsp.handlers'

          local jdtls_env = {
            HOME = vim.uv.os_homedir(),
            XDG_CACHE_HOME = os.getenv 'XDG_CACHE_HOME',
            JDTLS_JVM_ARGS = os.getenv 'JDTLS_JVM_ARGS',
          }

          local function get_cache_dir()
            return jdtls_env.XDG_CACHE_HOME and jdtls_env.XDG_CACHE_HOME or jdtls_env.HOME .. '/.cache'
          end

          local function get_jdtls_cache_dir()
            return get_cache_dir() .. '/jdtls'
          end

          local function get_jdtls_config_dir()
            return get_jdtls_cache_dir() .. '/config'
          end

          local function get_jdtls_workspace_dir()
            return get_jdtls_cache_dir() .. '/workspace'
          end

          local function get_jdtls_jvm_args()
            local args = {}
            for a in string.gmatch((jdtls_env.JDTLS_JVM_ARGS or '''), '%S+') do
              local arg = string.format('--jvm-arg=%s', a)
              table.insert(args, arg)
            end
            return unpack(args)
          end

          -- TextDocument version is reported as 0, override with nil so that
          -- the client doesn't think the document is newer and refuses to update
          -- See: https://github.com/eclipse/eclipse.jdt.ls/issues/1695
          local function jdtls_fix_zero_version(workspace_edit)
            if workspace_edit and workspace_edit.documentChanges then
              for _, change in pairs(workspace_edit.documentChanges) do
                local text_document = change.textDocument
                if text_document and text_document.version and text_document.version == 0 then
                  text_document.version = nil
                end
              end
            end
            return workspace_edit
          end

          local function jdtls_on_textdocument_codeaction(err, actions, ctx)
            for _, action in ipairs(actions) do
              -- TODO: (steelsojka) Handle more than one edit?
              if action.command == 'java.apply.workspaceEdit' then -- 'action' is Command in java format
                action.edit = jdtls_fix_zero_version(action.edit or action.arguments[1])
              elseif type(action.command) == 'table' and action.command.command == 'java.apply.workspaceEdit' then -- 'action' is CodeAction in java format
                action.edit = jdtls_fix_zero_version(action.edit or action.command.arguments[1])
              end
            end

            jdtls_handlers[ctx.method](err, actions, ctx)
          end

          local function jdtls_on_textdocument_rename(err, workspace_edit, ctx)
            jdtls_handlers[ctx.method](err, jdtls_fix_zero_version(workspace_edit), ctx)
          end

          local function jdtls_on_workspace_applyedit(err, workspace_edit, ctx)
            jdtls_handlers[ctx.method](err, jdtls_fix_zero_version(workspace_edit), ctx)
          end

          -- Non-standard notification that can be used to display progress
          local function jdtls_on_language_status(_, result)
            local command = vim.api.nvim_command
            command 'echohl ModeMsg'
            command(string.format('echo "%s"', result.message))
            command 'echohl None'
          end
        '';

      vim.lsp.servers =
        mapListToAttrs (n: {
          name = n;
          value = servers.${n};
        })
        cfg.lsp.servers;
    })

    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })
  ]);
}
