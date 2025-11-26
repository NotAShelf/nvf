{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.meta) getExe;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkOption mkEnableOption literalMD;
  inherit (lib.strings) optionalString;
  inherit (lib.lists) isList;
  inherit (lib.attrsets) attrNames;
  inherit (lib.types) bool package str listOf either enum int;
  inherit (lib.nvim.lua) expToLua toLuaObject;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.types) mkGrammarOption mkPluginSetupOption deprecatedSingleOrListOf;
  inherit (lib.nvim.dag) entryAfter entryAnywhere;

  cfg = config.vim.languages.rust;

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
      enable = mkEnableOption "Rust treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "rust";
    };

    lsp = {
      enable = mkEnableOption "Rust LSP support (rust-analyzer with extra tools)" // {default = config.vim.lsp.enable;};
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
      };

      package = mkOption {
        description = "lldb package";
        type = package;
        default = pkgs.lldb;
      };
    };

    extensions = {
      crates-nvim = {
        enable = mkEnableOption "crates.io dependency management [crates-nvim]";

        setupOpts = mkPluginSetupOption "crates-nvim" {
          lsp = {
            enabled = mkEnableOption "crates.nvim's in-process language server" // {default = cfg.extensions.crates-nvim.enable;};
            actions = mkEnableOption "actions for crates-nvim's in-process language server" // {default = cfg.extensions.crates-nvim.enable;};
            completion = mkEnableOption "completion for crates-nvim's in-process language server" // {default = cfg.extensions.crates-nvim.enable;};
            hover = mkEnableOption "hover actions for crates-nvim's in-process language server" // {default = cfg.extensions.crates-nvim.enable;};
          };
          completion = {
            crates = {
              enabled = mkEnableOption "completion for crates-nvim's in-process language server" // {default = cfg.extensions.crates-nvim.enable;};
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
              then expToLua cfg.lsp.package
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

    (mkIf cfg.extensions.crates-nvim.enable {
      vim = mkMerge [
        {
          startPlugins = ["crates-nvim"];
          pluginRC.rust-crates = entryAnywhere ''
            require("crates").setup(${toLuaObject cfg.extensions.crates-nvim.setupOpts})
          '';
        }
      ];
    })
  ]);
}
