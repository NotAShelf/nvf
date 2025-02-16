{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.types) package bool enum;
  inherit (lib.lists) isList;
  inherit (lib.meta) getExe;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.lua) expToLua toLuaObject;
  inherit (lib.nvim.languages) lspOptions;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.hcl;

  defaultServer = "terraform-ls";
  servers = {
    terraform-ls = {
      package = pkgs.terraform-ls;
      options = {
        capabilities = mkLuaInline "capabilities";
        on_attach = mkLuaInline "default_on_attach";
        filetypes = ["terraform" "hcl"];
        cmd =
          if isList cfg.lsp.package
          then expToLua cfg.lsp.package
          else ["${getExe cfg.lsp.package}" "serve"];
      };
    };
  };

  defaultFormat = "hclfmt";
  formats = {
    hclfmt = {
      package = pkgs.hclfmt;
      nullConfig = ''
        table.insert(
          ls_sources,
          null_ls.builtins.formatting.hclfmt.with({
            command = "${lib.getExe cfg.format.package}",
          })
        )
      '';
    };
  };
in {
  options.vim.languages.hcl = {
    enable = mkEnableOption "HCL support";

    treesitter = {
      enable = mkEnableOption "HCL treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "hcl";
    };

    lsp = {
      enable = mkEnableOption "HCL LSP support (terraform-ls)" // {default = config.vim.languages.enableLSP;};

      # TODO: (maybe, is it better?) it would be cooler to use vscode-extensions.hashicorp.hcl probably, shouldn't be too hard
      package = mkOption {
        type = package;
        default = servers.${defaultServer}.package;
        description = "HCL language server package (terraform-ls)";
      };

      server = mkOption {
        description = "HCL LSP server to use";
        type = enum (attrNames servers);
        default = defaultServer;
      };

      options = mkOption {
        type = lspOptions;
        default = servers.${cfg.lsp.server}.options;
        description = ''
          LSP options for HCL language support.

          This option is freeform, you may add options that are not set by default
          and they will be merged into the final table passed to lspconfig.
        '';
      };
    };

    format = {
      enable = mkOption {
        type = bool;
        default = config.vim.languages.enableFormat;
        description = "Enable HCL formatting";
      };

      type = mkOption {
        type = enum (attrNames formats);
        default = defaultFormat;
        description = "HCL formatter to use";
      };

      package = mkOption {
        type = package;
        default = formats.${cfg.format.type}.package;
        description = "HCL formatter package";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      # HCL style official: https://developer.hashicorp.com/terraform/language/style#code-formatting
      vim.pluginRC.hcl = ''
        vim.api.nvim_create_autocmd("FileType", {
          pattern = "hcl",
          callback = function(opts)
            local bo = vim.bo[opts.buf]
            bo.tabstop = 2
            bo.shiftwidth = 2
            bo.softtabstop = 2
          end
        })

        local ft = require('Comment.ft')
        ft
          .set('hcl', '#%s')
      '';
    }

    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.lspconfig = {
        enable = true;
        sources.hcl-lsp = lib.optionalString (!config.vim.languages.terraform.lsp.enable) ''
          lspconfig.${toLuaObject cfg.lsp.server}.setup(${toLuaObject cfg.lsp.options})
        '';
      };
    })

    (mkIf cfg.format.enable {
      vim.lsp.null-ls.enable = true;
      vim.lsp.null-ls.sources.hcl-format = formats.${cfg.format.type}.nullConfig;
    })
  ]);
}
