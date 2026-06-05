{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib) genAttrs;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkOption mkEnableOption literalMD literalExpression;
  inherit (lib.attrsets) attrNames;
  inherit (lib.types) bool package listOf enum int;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.dag) entryAfter;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.types) mkGrammarOption mkPluginSetupOption deprecatedSingleOrListOf;
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
        description = "lldb package";
        type = package;
        default = pkgs.lldb;
      };

      adapter = mkOption {
        type = enum ["lldb-dap" "codelldb"];
        default = "codelldb";
        description = ''
          Select which LLDB-based debug adapter to use:

          - "codelldb": use the CodeLLDB adapter from the vadimcn.vscode-lldb extension.
          - "lldb-dap": use the LLDB DAP implementation shipped with LLVM (lldb-dap).

          The default "codelldb" backend generally provides a better debugging experience for Rust.
        '';
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
                if cfg.dap.adapter == "lldb-dap"
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
          assertion = !cfg.lsp.enable;
          message = "rustaceanvim and vim.languages.rust.lsp.enable are mutually exclusive. Please ensure `vim.lsp.rust-analyzer.enable` is false, or disable `vim.languages.rust.lsp.enable`.";
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
