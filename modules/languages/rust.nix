{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.strings) optionalString;
  inherit (lib.trivial) boolToString;
  inherit (lib.lists) isList optionals;
  inherit (lib.types) bool package str listOf either;
  inherit (lib.nvim.types) mkGrammarOption;
  inherit (lib.nvim.lua) expToLua;
  inherit (lib.nvim.dag) entryAnywhere;

  cfg = config.vim.languages.rust;
in {
  options.vim.languages.rust = {
    enable = mkEnableOption "Rust language support";

    treesitter = {
      enable = mkEnableOption "Rust treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "rust";
    };

    crates = {
      enable = mkEnableOption "crates-nvim, tools for managing dependencies";
      codeActions = mkOption {
        description = "Enable code actions through null-ls";
        type = bool;
        default = true;
      };
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
      };
    };

    dap = {
      enable = mkOption {
        description = "Rust Debug Adapter support";
        type = bool;
        default = config.vim.languages.enableDAP;
      };

      package = mkOption {
        description = "lldb pacakge";
        type = package;
        default = pkgs.lldb;
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.crates.enable {
      vim = {
        startPlugins = ["crates-nvim"];
        lsp.null-ls.enable = mkIf cfg.crates.codeActions true;
        autocomplete.sources = {"crates" = "[Crates]";};
        luaConfigRC.rust-crates = entryAnywhere ''
          require('crates').setup {
            null_ls = {
              enabled = ${boolToString cfg.crates.codeActions},
              name = "crates.nvim",
            }
          }
        '';
      };
    })

    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf (cfg.lsp.enable || cfg.dap.enable) {
      vim = {
        startPlugins = ["rust-tools"] ++ optionals cfg.dap.enable [cfg.dap.package];

        lsp.lspconfig = {
          enable = true;
          sources.rust-lsp = ''
            local rt = require('rust-tools')
            rust_on_attach = function(client, bufnr)
              default_on_attach(client, bufnr)
              local opts = { noremap=true, silent=true, buffer = bufnr }
              vim.keymap.set("n", "<leader>ris", rt.inlay_hints.set, opts)
              vim.keymap.set("n", "<leader>riu", rt.inlay_hints.unset, opts)
              vim.keymap.set("n", "<leader>rr", rt.runnables.runnables, opts)
              vim.keymap.set("n", "<leader>rp", rt.parent_module.parent_module, opts)
              vim.keymap.set("n", "<leader>rm", rt.expand_macro.expand_macro, opts)
              vim.keymap.set("n", "<leader>rc", rt.open_cargo_toml.open_cargo_toml, opts)
              vim.keymap.set("n", "<leader>rg", function() rt.crate_graph.view_crate_graph("x11", nil) end, opts)
              ${optionalString cfg.dap.enable ''
              vim.keymap.set("n", "<leader>rd", ":RustDebuggables<cr>", opts)
              vim.keymap.set(
                "n", "${config.vim.debugger.nvim-dap.mappings.continue}",
                function()
                  local dap = require("dap")
                  if dap.status() == "" then
                    vim.cmd "RustDebuggables"
                  else
                    dap.continue()
                  end
                end,
                opts
              )
            ''}
            end
            local rustopts = {
              tools = {
                autoSetHints = true,
                hover_with_actions = false,
                inlay_hints = {
                  only_current_line = false,
                }
              },
              server = {
                capabilities = capabilities,
                on_attach = rust_on_attach,
                cmd = ${
              if isList cfg.lsp.package
              then expToLua cfg.lsp.package
              else ''{"${cfg.lsp.package}/bin/rust-analyzer"}''
            },
                settings = {
                  ${cfg.lsp.opts}
                }
              },

              ${optionalString cfg.dap.enable ''
              dap = {
                adapter = {
                  type = "executable",
                  command = "${cfg.dap.package}/bin/lldb-vscode",
                  name = "rt_lldb",
                },
              },
            ''}
            }
            rt.setup(rustopts)
          '';
        };
      };
    })
  ]);
}
