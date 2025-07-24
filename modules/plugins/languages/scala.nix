{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.generators) mkLuaInline;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.binds) mkMappingOption;
  inherit (lib.nvim.dag) entryAfter;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.types) mkGrammarOption luaInline;
  inherit (lib.options) mkOption mkEnableOption mkPackageOption;
  inherit (lib.strings) optionalString;
  inherit (lib.types) attrsOf anything bool;

  listCommandsAction =
    if config.vim.telescope.enable
    then ''require("telescope").extensions.metals.commands()''
    else ''require("metals").commands()'';

  cfg = config.vim.languages.scala;

  usingDap = config.vim.debugger.nvim-dap.enable && cfg.dap.enable;
  usingLualine = config.vim.statusline.lualine.enable;
in {
  options.vim.languages.scala = {
    enable = mkEnableOption "Scala language support";

    treesitter = {
      enable = mkEnableOption "Scala treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "scala";
    };

    lsp = {
      enable = mkEnableOption "Scala LSP support (metals)" // {default = config.vim.lsp.enable;};
      package = mkPackageOption pkgs "metals" {
        default = ["metals"];
      };

      extraMappings = {
        listCommands = mkMappingOption config.vim.enableNvfKeymaps "List Metals commands" "<leader>lc";
      };

      extraSettings = mkOption {
        type = attrsOf anything;
        description = "Extra settings passed to the metals config. Check nvim-metals docs for available options";
        default = {
          showImplicitArguments = true;
          showImplicitConversionsAndClasses = true;
          showInferredType = true;
          excludedPackages = [
            "akka.actor.typed.javadsl"
            "com.github.swagger.akka.javadsl"
          ];
        };
      };
    };

    dap = {
      enable = mkEnableOption "Scala Debug Adapter support (metals)" // {default = config.vim.languages.enableDAP;};
      config = mkOption {
        description = "Lua configuration for dap";
        type = luaInline;
        default = mkLuaInline ''
          dap.configurations.scala = {
            {
              type = "scala",
              request = "launch",
              name = "RunOrTest",
              metals = {
                runType = "runOrTestFile",
                --args = { "firstArg", "secondArg", "thirdArg" }, -- here just as an example
              },
            },
            {
              type = "scala",
              request = "launch",
              name = "Test Target",
              metals = {
                runType = "testTarget",
              },
            },
          }
        '';
      };
    };

    fixShortmess = mkOption {
      type = bool;
      description = "Remove the 'F' flag from shortmess to allow messages to be shown. Without doing this, autocommands that deal with filetypes prohibit messages from being shown";
      default = true;
    };
  };

  config = mkIf cfg.enable (
    mkMerge [
      (mkIf cfg.treesitter.enable {
        vim.treesitter.enable = true;
        vim.treesitter.grammars = [cfg.treesitter.package];
      })
      (mkIf (cfg.lsp.enable || cfg.dap.enable) {
        vim = {
          startPlugins = ["nvim-metals"];
          pluginRC.nvim-metals = entryAfter ["lsp-setup"] ''
            local metals_caps = capabilities  -- from lsp-setup

            local attach_metals_keymaps = function(client, bufnr)
              attach_keymaps(client, bufnr)  -- from lsp-setup
              vim.api.nvim_buf_set_keymap(bufnr, 'n', '${cfg.lsp.extraMappings.listCommands}', '<cmd>lua ${listCommandsAction}<CR>', {noremap=true, silent=true, desc='Show all Metals commands'})
            end

            metals_config = require('metals').bare_config()
            ${optionalString usingLualine "metals_config.init_options.statusBarProvider = 'on'"}

            metals_config.capabilities = metals_caps
            metals_config.on_attach = function(client, bufnr)
              ${optionalString usingDap "require('metals').setup_dap()"}
              attach_metals_keymaps(client, bufnr)
            end

            metals_config.settings = ${toLuaObject cfg.lsp.extraSettings}
            metals_config.settings.metalsBinaryPath = "${cfg.lsp.package}/bin/metals"

            metals_config.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
              vim.lsp.diagnostic.on_publish_diagnostics, {
                virtual_text = {
                  prefix = '⚠',
                }
              }
            )

            ${optionalString cfg.fixShortmess ''vim.opt_global.shortmess:remove("F")''}

            local lsp_group = vim.api.nvim_create_augroup('lsp', { clear = true })

            vim.api.nvim_create_autocmd('FileType', {
                group = lsp_group,
                pattern = {'java', 'scala', 'sbt'},
                callback = function()
                    require('metals').initialize_or_attach(metals_config)
                end,
            })
          '';
        };
      })
    ]
  );
}
