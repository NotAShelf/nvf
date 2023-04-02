{
  pkgs,
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  cfg = config.vim.lsp;
in {
  options.vim.lsp = {
    enable = mkEnableOption "Enable neovim lsp support. Requires language specific LSPs to be anabled to take effect";
    formatOnSave = mkEnableOption "Format on save";
    nix = {
      enable = mkEnableOption "Nix LSP";
      server = mkOption {
        type = with types; enum ["rnix" "nil"];
        default = "nil";
        description = "Which LSP to use";
      };

      pkg = mkOption {
        type = types.package;
        default =
          if (cfg.nix.server == "rnix")
          then pkgs.rnix-lsp
          else pkgs.nil;
        description = "The LSP package to use";
      };

      formatter = mkOption {
        type = with types; enum ["nixpkgs-fmt" "alejandra"];
        default = "alejandra";
        description = "Which nix formatter to use";
      };
    };
    rust = {
      enable = mkEnableOption "Rust LSP";
      rustAnalyzerOpts = mkOption {
        type = types.str;
        default = ''
          ["rust-analyzer"] = {
            experimental = {
              procAttrMacros = true,
            },
          },
        '';
        description = "Options to pass to rust analyzer";
      };
    };
    python = mkEnableOption "Python LSP";
    clang = {
      enable = mkEnableOption "C language LSP";
      c_header = mkEnableOption "C syntax header files";
      cclsOpts = mkOption {
        type = types.str;
        default = "";
      };
    };
    sql = mkEnableOption "SQL Language LSP";
    go = mkEnableOption "Go language LSP";
    ts = mkEnableOption "TS language LSP";
    zig.enable = mkEnableOption "Zig language LSP";
  };
}
