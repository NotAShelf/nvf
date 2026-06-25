{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkOption mkEnableOption literalMD literalExpression;
  inherit (lib.attrsets) attrNames genAttrs;
  inherit (lib.lists) flatten;
  inherit (lib.types) bool package listOf enum int;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.dag) entryAfter;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.types) mkGrammarOption mkPluginSetupOption deprecatedSingleOrListOf enumWithRename;
  inherit (lib.strings) optionalString;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.languages.rust;

  servers = ["rust-analyzer"];
  defaultServers = ["rust-analyzer"];

  defaultFormat = ["rustfmt"];
  formats = {
    rustfmt = {
      command = getExe pkgs.rustfmt;
    };
  };

  defaultDebugger = ["codelldb"];
  dapConfigurations = {
    lldb = [
      {
        name = "Launch file";
        type = "lldb";
        request = "launch";
        program = mkLuaInline ''
          function()
            return nvf_dap_cached_input(
              'rust_lldb_launch_exe',
              "Path to executable: ",
              vim.fn.getcwd() .. "/target/debug/",
              "file")
          end
        '';
        cwd = "\${workspaceFolder}";
        stopOnEntry = false;
        args = [];
      }
    ];
    codelldb = [
      {
        name = "Launch file";
        type = "codelldb";
        request = "launch";
        program = mkLuaInline ''
          function()
            return nvf_dap_cached_input(
              'rust_codelldb_launch_exe',
              "Path to executable: ",
              vim.fn.getcwd() .. "/target/debug/",
              "file")
          end
        '';
        cwd = "\${workspaceFolder}";
        stopOnEntry = false;
        args = [];
      }
    ];
  };
in {
  options.vim.languages.rust = {
    enable = mkEnableOption "Rust language support";

    treesitter = {
      enable =
        mkEnableOption "Rust treesitter"
        // {
          default = config.vim.languages.enableTreesitter;
          defaultText = literalExpression "config.vim.languages.enableTreesitter";
        };
      package = mkGrammarOption pkgs "rust";
    };

    lsp = {
      enable =
        mkEnableOption "Rust LSP support"
        // {
          default = config.vim.lsp.enable;
          defaultText = literalExpression "config.vim.lsp.enable";
        };

      servers = mkOption {
        type = listOf (enum servers);
        default = defaultServers;
        description = "Rust LSP server to use";
      };
    };

    format = {
      enable =
        mkEnableOption "Rust formatting"
        // {
          default = !cfg.lsp.enable && config.vim.languages.enableFormat;
          defaultText = literalMD ''
            Disabled if Rust LSP is enabled, otherwise follows {option}`vim.languages.enableFormat`
          '';
        };

      type = mkOption {
        description = "Rust formatter to use";
        type = deprecatedSingleOrListOf "vim.language.rust.format.type" (enum (attrNames formats));
        default = defaultFormat;
      };
    };

    dap = {
      enable = mkOption {
        description = "Rust Debug Adapter support";
        type = bool;
        default = config.vim.languages.enableDAP;
        defaultText = literalExpression "config.vim.languages.enableDAP";
      };

      package = mkOption {
        description = "lldb package, used when the lldb debugger is selected";
        type = package;
        default = pkgs.lldb;
      };

      debugger = mkOption {
        description = ''
          Rust debugger to use.

          - `"codelldb"`: use the CodeLLDB adapter from the vadimcn.vscode-lldb extension.
            Generally provides a better debugging experience for Rust.
          - `"lldb"`: use the LLDB DAP implementation shipped with LLVM (`lldb-dap`).
        '';
        type =
          deprecatedSingleOrListOf "vim.languages.rust.dap.debugger"
          (enumWithRename "vim.languages.rust.dap.debugger" (attrNames dapConfigurations) {
            "lldb-dap" = "lldb";
          });
        default = defaultDebugger;
      };
    };

    extensions = {
      crates-nvim = {
        enable = mkEnableOption "crates.io dependency management [crates-nvim]";

        setupOpts = mkPluginSetupOption "crates-nvim" {
          lsp = {
            enabled =
              mkEnableOption "crates.nvim's in-process language server"
              // {
                default = cfg.extensions.crates-nvim.enable;
                defaultText = literalExpression "config.vim.languages.rust.extensions.crates-nvim.enable";
              };
            actions =
              mkEnableOption "actions for crates-nvim's in-process language server"
              // {
                default = cfg.extensions.crates-nvim.enable;
                defaultText = literalExpression "config.vim.languages.rust.extensions.crates-nvim.enable";
              };
            completion =
              mkEnableOption "completion for crates-nvim's in-process language server"
              // {
                default = cfg.extensions.crates-nvim.enable;
                defaultText = literalExpression "config.vim.languages.rust.extensions.crates-nvim.enable";
              };
            hover =
              mkEnableOption "hover actions for crates-nvim's in-process language server"
              // {
                default = cfg.extensions.crates-nvim.enable;
                defaultText = literalExpression "config.vim.languages.rust.extensions.crates-nvim.enable";
              };
          };
          completion = {
            crates = {
              enabled =
                mkEnableOption "completion for crates-nvim's in-process language server"
                // {
                  default = cfg.extensions.crates-nvim.enable;
                  defaultText = literalExpression "config.vim.languages.rust.extensions.crates-nvim.enable";
                };
              max_results = mkOption {
                description = "The maximum number of search results to display";
                type = int;
                default = 8;
              };
              min_chars = mkOption {
                description = "The minimum number of characters to type before completions begin appearing";
                type = int;
                default = 3;
              };
            };
          };
        };
      };

      rustaceanvim = {
        enable = mkEnableOption "additional rust support [rustaceanvim]";
        setupOpts = mkPluginSetupOption "rustaceanvim" {
          tools = mkOption {
            description = "Plugin configuration";
            default = {
              hover_actions = {
                replace_builtin_hover = false;
              };
            };
            example = {
              hover_actions = {
                replace_builtin_hover = true;
              };
            };
          };
          server = mkOption {
            description = "LSP configuration";
            default = {
              # For some reason rustaceanvim needs the command set explicitly, and does not pick up on vim.lsp.config settings.
              cmd = [(getExe pkgs.rust-analyzer)];

              on_attach = mkLuaInline ''
                function(client, bufnr)
                    default_on_attach(client, bufnr)
                    local opts = { noremap=true, silent=true, buffer = bufnr }

                    ${optionalString config.vim.vendoredKeymaps.enable ''
                  vim.keymap.set("n", "<localleader>rr", ":RustLsp runnables<CR>", opts)
                  vim.keymap.set("n", "<localleader>rp", ":RustLsp parentModule<CR>", opts)
                  vim.keymap.set("n", "<localleader>rm", ":RustLsp expandMacro<CR>", opts)
                  vim.keymap.set("n", "<localleader>rc", ":RustLsp openCargo", opts)
                  vim.keymap.set("n", "<localleader>rg", ":RustLsp crateGraph x11", opts)
                ''}

                    ${optionalString (cfg.dap.enable && config.vim.vendoredKeymaps.enable) ''
                  vim.keymap.set("n", "<localleader>rd", ":RustLsp debuggables<cr>", opts)
                ''}

                    ${optionalString (cfg.dap.enable && config.vim.debugger.nvim-dap.mappings.continue != null) ''
                  vim.keymap.set(
                  "n", "${config.vim.debugger.nvim-dap.mappings.continue}",
                  function()
                    local dap = require("dap")
                    if dap.status() == "" then
                      vim.cmd "RustLsp debuggables"
                    else
                      dap.continue()
                    end
                  end,
                  opts
                  )
                ''}
                end
              '';
            };
            example = {
              on_attach = mkLuaInline ''
                function(client, bufnr)
                      -- you can also put keymaps in here
                end,
              '';
            };
          };
          dap = mkOption {
            description = "DAP configuration";
            default = {
              adapter =
                if builtins.elem "lldb" cfg.dap.debugger
                then
                  mkLuaInline ''
                    {
                      type = "executable",
                      command = "${cfg.dap.package}/bin/lldb-dap",
                      name = "rustacean_lldb",
                    }''
                else let
                  codelldb = pkgs.vscode-extensions.vadimcn.vscode-lldb.adapter;
                  codelldbPath = "${codelldb}/bin/codelldb";
                  liblldbPath = "${codelldb}/share/lldb/lib/liblldb.so";
                in
                  mkLuaInline ''
                    require("rustaceanvim.config").get_codelldb_adapter("${codelldbPath}", "${liblldbPath}")
                  '';
            };
            example = {};
          };
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.format.enable {
      vim.formatter.conform-nvim = {
        enable = true;
        setupOpts = {
          formatters_by_ft.rust = cfg.format.type;
          formatters =
            mapListToAttrs (name: {
              inherit name;
              value = formats.${name};
            })
            cfg.format.type;
        };
      };
    })

    (mkIf cfg.lsp.enable {
      vim.lsp = {
        presets = genAttrs cfg.lsp.servers (_: {enable = true;});
        servers = genAttrs cfg.lsp.servers (_: {
          filetypes = [
            "rust"
          ];
        });
      };
    })

    (mkIf cfg.dap.enable {
      vim.debugger.nvim-dap = {
        enable = true;
        presets = genAttrs cfg.dap.debugger (_: {enable = true;});
        configurations.rust = flatten (map (name: dapConfigurations.${name}) cfg.dap.debugger);
      };
    })

    (mkIf cfg.extensions.rustaceanvim.enable {
      vim = {
        startPlugins = ["rustaceanvim"];
        pluginRC.rustaceanvim = entryAfter ["lsp-setup"] ''
          vim.g.rustaceanvim = function()
            return ${toLuaObject cfg.extensions.rustaceanvim.setupOpts}
          end
        '';
      };

      assertions = [
        {
          assertion = !(builtins.elem "rust-analyzer" cfg.lsp.servers) && !config.vim.lsp.rust-analyzer.enable;
          message = ''
            Rustaceanvim fully manages its own rust-analyzer.
            Therefore you can't use vim.languages.rust.extensions.rustaceanvim.enable with rust-analyzer enabled.
          '';
        }
      ];
    })

    (mkIf cfg.extensions.crates-nvim.enable {
      vim = mkMerge [
        {
          lazy.plugins.crates-nvim = {
            package = "crates-nvim";
            setupModule = "crates";
            setupOpts = cfg.extensions.crates-nvim.setupOpts;
            event = [
              {
                event = "BufRead";
                pattern = "Cargo.toml";
              }
            ];
          };
        }
      ];
    })
  ]);
}
