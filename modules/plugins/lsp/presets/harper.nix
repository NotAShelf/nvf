{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.meta) getExe;

  cfg = config.vim.lsp.presets.harper;
  filetypes = [
    # <https://writewithharper.com/docs/integrations/language-server#Supported-Languages>
    "asciidoc"
    "c"
    "clojure"
    "cmake"
    "cpp"
    "cs"
    "dart"
    "gitcommit"
    "go"
    "haskell"
    "html"
    "java"
    "javascript"
    "javascriptreact"
    "kotlin"
    "lhaskell"
    "lua"
    "mail"
    "markdown"
    "nix"
    "php"
    "python"
    "ruby"
    "rust"
  ];
in {
  options.vim.lsp.presets.harper = {
    enable = mkLspPresetEnableOption {
      option = "harper";
      display = "Harper";
      defaultFiletypes = filetypes;
    };
  };

  config = mkIf cfg.enable {
    vim.lsp.servers.harper = {
      enable = true;
      cmd = [(getExe pkgs.harper) "--stdio"];
      root_markers = [".git" ".harper-dictionary.txt"];
      # Make Harper shut up in the logs, that its key is required, when nothing is configured.
      settings.harper-ls = {};
      inherit filetypes;
    };
  };
}
