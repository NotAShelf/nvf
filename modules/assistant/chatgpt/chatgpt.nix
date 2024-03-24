{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib) mkMappingOption;
in {
  options.vim.assistant.chatgpt = {
    enable = mkEnableOption "ChatGPT AI assistant. Requires the environment variable OPENAI_API_KEY to be set";
    mappings = {
      chatGpt = mkMappingOption "ChatGPT" "<leader>ac";
      editWithInstructions = mkMappingOption "[ChatGPT] Edit with instructions" "<leader>ae";
      grammarCorrection = mkMappingOption "[ChatGPT] Grammar correction" "<leader>ag";
      translate = mkMappingOption "[ChatGPT] Translate" "<leader>at";
      keyword = mkMappingOption "[ChatGPT] Keywords" "<leader>ak";
      docstring = mkMappingOption "[ChatGPT] Docstring" "<leader>ad";
      addTests = mkMappingOption "[ChatGPT] Add tests" "<leader>aa";
      optimize = mkMappingOption "[ChatGPT] Optimize code" "<leader>ao";
      summarize = mkMappingOption "[ChatGPT] Summarize" "<leader>as";
      fixBugs = mkMappingOption "[ChatGPT] Fix bugs" "<leader>af";
      explain = mkMappingOption "[ChatGPT] Explain code" "<leader>ax";
      roxygenEdit = mkMappingOption "[ChatGPT] Roxygen edit" "<leader>ar";
      readabilityanalysis = mkMappingOption "[ChatGPT] Code reability analysis" "<leader>al";
    };
  };
}
