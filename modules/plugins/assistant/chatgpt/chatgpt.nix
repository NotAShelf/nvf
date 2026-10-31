{
  config,
  lib,
  ...
}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
  mkMappingOption = config.vim.lib.mkMappingOption "ChatGPT";
in {
  options.vim.assistant.chatgpt = {
    enable = mkEnableOption "ChatGPT AI assistant. Requires the environment variable OPENAI_API_KEY to be set";
    setupOpts = mkPluginSetupOption "chatgpt" {};
    mappings = {
      chatGpt = mkMappingOption "Open" "<leader>ac";
      editWithInstructions = mkMappingOption "Edit with instructions" "<leader>ae";
      grammarCorrection = mkMappingOption "Grammar correction" "<leader>ag";
      translate = mkMappingOption "Translate" "<leader>at";
      keyword = mkMappingOption "Keywords" "<leader>ak";
      docstring = mkMappingOption "Docstring" "<leader>ad";
      addTests = mkMappingOption "Add tests" "<leader>aa";
      optimize = mkMappingOption "Optimize code" "<leader>ao";
      summarize = mkMappingOption "Summarize" "<leader>as";
      fixBugs = mkMappingOption "Fix bugs" "<leader>af";
      explain = mkMappingOption "Explain code" "<leader>ax";
      roxygenEdit = mkMappingOption "Roxygen edit" "<leader>ar";
      readabilityanalysis = mkMappingOption "Code reability analysis" "<leader>al";
    };
  };
}
