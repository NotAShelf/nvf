{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) isList attrNames;
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge mkRenamedOptionModule;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.strings) optionalString;
  inherit (lib.trivial) boolToString;
  inherit (lib.types) bool package str listOf either enum;
  inherit (lib.nvim.types) mkGrammarOption mkPluginSetupOption;
  inherit (lib.nvim.lua) toLuaObject;
  inherit (lib.nvim.dag) entryAfter entryAnywhere;

  cfg = config.vim.languages.rust;

  defaultFormat = "rustfmt";
  formats = {
    rustfmt = {
      package = pkgs.rustfmt;
    };
  };
in {
  imports = [
    (mkRenamedOptionModule ["vim" "languages" "rust" "crates"] ["vim" "languages" "rust" "extensions" "crates-nvim"])
  ];

  options.vim.languages.rust = {
    enable = mkEnableOption "Rust language support";

    treesitter = {
      enable = mkEnableOption "Rust treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "rust";
    };

    lsp = {
      enable = mkEnableOption "Rust LSP support (rust-analyzer with extra tools)" // {default = config.vim.languages.enableLSP;};
      package = mkOption {
        description = "rust-analyzer package, or the command to run as a list of strings";
        example = ''[lib.getExe pkgs.jdt-language-server "-data" "~/.cache/jdtls/workspace"]'';
        type = either package (listOf str);
        default = pkgs.rust-analyzer;
      };

      opts = mkOption {
        description = "Options to pass to rust analyzer";
        type = str;
        default = "";
        example = ''
          ['rust-analyzer'] = {
            cargo = {allFeature = true},
            checkOnSave = true,
            procMacro = {
              enable = true,
            },
          },
        '';
      };
    };

    format = {
      enable = mkEnableOption "Rust formatting" // {default = config.vim.languages.enableFormat;};

      type = mkOption {
        description = "Rust formatter to use";
        type = enum (attrNames formats);
        default = defaultFormat;
      };

      package = mkOption {
        description = "Rust formatter package";
        type = package;
        default = formats.${cfg.format.type}.package;
      };
    };

    dap = {
      enable = mkOption {
        description = "Rust Debug Adapter support";
        type = bool;
        default = config.vim.languages.enableDAP;
      };

      package = mkOption {
        description = "lldb package";
        type = package;
        default = pkgs.lldb;
      };
    };

    extensions = {
      crates-nvim = {
        enable =
          mkEnableOption ""
          // {
            default = true;
            description = ''
              [crates.nvim]: https://github.com/Saecki/crates.nvim/

              Helper plugin for managing crates.io dependencies [crates.nvim]
            '';
          };

        setupOpts = mkPluginSetupOption "crates-nvim" {};
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
        setupOpts.formatters_by_ft.rust = [cfg.format.type];
        setupOpts.formatters.${cfg.format.type} = {
          command = getExe cfg.format.package;
        };
      };
    })

    (mkIf (cfg.lsp.enable || cfg.dap.enable) {
      vim = {
        startPlugins = ["rustaceanvim"];

        pluginRC.rustaceanvim = entryAfter ["lsp-setup"] ''
          vim.g.rustaceanvim = {
          ${optionalString cfg.lsp.enable ''
            -- LSP
            tools = {
              hover_actions = {
                replace_builtin_hover = false
              },
            },
            server = {
              cmd = ${
              if isList cfg.lsp.package
              then toLuaObject cfg.lsp.package
              else ''{"${cfg.lsp.package}/bin/rust-analyzer"}''
            },
              default_settings = {
                ${cfg.lsp.opts}
              },
              on_attach = function(client, bufnr)
                default_on_attach(client, bufnr)
                local opts = { noremap=true, silent=true, buffer = bufnr }
                vim.keymap.set("n", "<localleader>rr", ":RustLsp runnables<CR>", opts)
                vim.keymap.set("n", "<localleader>rp", ":RustLsp parentModule<CR>", opts)
                vim.keymap.set("n", "<localleader>rm", ":RustLsp expandMacro<CR>", opts)
                vim.keymap.set("n", "<localleader>rc", ":RustLsp openCargo", opts)
                vim.keymap.set("n", "<localleader>rg", ":RustLsp crateGraph x11", opts)
                ${optionalString cfg.dap.enable ''
              vim.keymap.set("n", "<localleader>rd", ":RustLsp debuggables<cr>", opts)
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
            },
          ''}

            ${optionalString cfg.dap.enable ''
            dap = {
              adapter = {
                type = "executable",
                command = "${cfg.dap.package}/bin/lldb-dap",
                name = "rustacean_lldb",
              },
            },
          ''}
          }
        '';
      };
    })

    # Extensions
    (mkIf cfg.extensions.crates.enable {
      vim = {
        startPlugins = ["crates-nvim"];
        autocomplete.nvim-cmp.sources = {crates = "[Crates]";};

        pluginRC.rust-crates-nvim = entryAnywhere ''
          require('crates').setup {
            null_ls = {
              enabled = ${boolToString cfg.crates.codeActions},
              name = "crates.nvim",
            }
          }
        '';
      };
    })
  ]);
}
