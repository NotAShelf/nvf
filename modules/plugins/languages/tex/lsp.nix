{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) getExe;
  inherit (lib.attrsets) attrNames;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.nvim.types) deprecatedSingleOrListOf;
  inherit (lib.types) enum;
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.attrsets) mapListToAttrs;

  cfg = config.vim.languages.tex;

  # **===========================================**
  # ||          <<<<< LSP SERVERS >>>>>          ||
  # **===========================================**

  defaultServers = ["texlab"];

  servers = {
    texlab = {
      cmd = [(getExe pkgs.texlab)];
      filetypes = ["tex" "plaintex" "context"];
      root_markers = [".git"];
      capabilities = {
        settings.texlab = {
          # -- Completion --
          completion.matcher = "fuzzy-ignore-case";

          # -- Diagnostics --
          diagnosticsDelay = 300;

          # -- Formatters --
          formatterLineLength = 80;
          bibtexFormatter = "texlab";
          latexFormatter = "latexindent";

          # -- Inlay Hints --
          inlayHints = {
            labelDefinitions = true;
            labelReferences = true;
          };
        };
      };
    };
  };
in {
  options.vim.languages.tex.lsp = {
    enable = mkEnableOption "TeX LSP support" // {default = config.vim.lsp.enable;};

    servers = mkOption {
      description = "The TeX LSP servers to use";
      type = deprecatedSingleOrListOf "vim.language.tex.lsp.servers" (enum (attrNames servers));
      default = defaultServers;
    };
  };

  config = mkIf (cfg.enable && cfg.enable) {
    vim.lsp.servers =
      mapListToAttrs (name: {
        inherit name;
        value = servers.${name};
      })
      cfg.lsp.servers;
  };
}
