{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.meta) getExe getExe';
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) enum listOf str;
  inherit (lib.nvim.attrsets) mapListToAttrs;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.arduino;

  defaultServers = ["arduino-language-server"];
  servers = {
    arduino-language-server = {
      enable = true;
      cmd =
        [
          (getExe pkgs.arduino-language-server)
          "-clangd"
          (getExe' pkgs.clang-tools "clangd")
          "-cli"
          (getExe pkgs.arduino-cli)
          "-cli-config"
          "$HOME/.arduino15/arduino-cli.yaml"
        ]
        ++ cfg.lsp.extraArgs;
      filetypes = ["arduino"];
      root_dir =
        mkLuaInline
        /*
        lua
        */
        ''
          function(bufnr, on_dir)
            local fname = vim.api.nvim_buf_get_name(bufnr)
            on_dir(util.root_pattern("*.ino")(fname))
          end
        '';
      capabilities = {
        textDocument = {
          semanticTokens = mkLuaInline "vim.NIL";
        };
        workspace = {
          semanticTokens = mkLuaInline "vim.NIL";
        };
      };
    };
  };
in {
  options.vim.languages.arduino = {
    enable = mkEnableOption "Arduino support";

    treesitter = {
      enable = mkEnableOption "Arduino treesitter" // {default = config.vim.languages.enableTreesitter;};
      package = mkGrammarOption pkgs "arduino";
    };

    lsp = {
      enable = mkEnableOption "Arduino LSP support" // {default = config.vim.lsp.enable;};
      servers = mkOption {
        type = listOf (enum (attrNames servers));
        default = defaultServers;
        description = "Arduino LSP servers to use";
      };

      extraArgs = mkOption {
        type = listOf str;
        default = [];
        description = "Extra arguments passed to the Arduino LSP";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.treesitter.enable {
      vim.treesitter.enable = true;
      vim.treesitter.grammars = [cfg.treesitter.package];
    })

    (mkIf cfg.lsp.enable {
      vim.lsp.servers =
        mapListToAttrs (n: {
          name = n;
          value = servers.${n};
        })
        cfg.lsp.servers;
    })
  ]);
}
