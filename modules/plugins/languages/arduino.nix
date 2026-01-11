{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (builtins) attrNames;
  inherit (lib.generators) mkLuaInline;
  inherit (lib.lists) optionals;
  inherit (lib.meta) getExe getExe';
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) enum listOf nullOr package str;
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
          (
            if cfg.lsp.clangdPackage == null
            then "clangd"
            else getExe' cfg.lsp.clangdPackage "clangd"
          )
          "-cli"
          (
            if cfg.lsp.cliPackage == null
            then "arduino-cli"
            else getExe cfg.lsp.cliPackage
          )
          "-cli-config"
          cfg.lsp.cliConfigPath
          "-fqbn"
          cfg.lsp.fqbn
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

      clangdPackage = mkOption {
        type = nullOr package;
        default = pkgs.clang-tools;
        description = "clangd package to be used by the Arduino LSP";
      };

      cliPackage = mkOption {
        type = nullOr package;
        default = pkgs.arduino-cli;
        description = "arduino-cli package to be used by the Arduino LSP";
      };

      cliConfigPath = mkOption {
        type = str;
        default = "$HOME/.arduino15/arduino-cli.yaml";
        description = "Path to the arduino-cli config to be used by the Arduino LSP";
      };

      fqbn = mkOption {
        type = str;
        description = "Fully Qualified Board Name to be used by the Arduino LSP";
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
