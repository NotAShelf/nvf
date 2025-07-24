{lib, ...}: let
  inherit (lib.options) mkEnableOption;
  inherit (lib.nvim.binds) mkMappingOption;
  inherit (lib.nvim.types) mkPluginSetupOption;
in {
  options.vim.assistant.chatgpt = {
    enable = mkEnableOption "ChatGPT AI assistant. Requires the environment variable OPENAI_API_KEY to be set";
    setupOpts = mkPluginSetupOption "chatgpt" {};
    mappings = {
      chatGpt = mkMappingOption config.vim.enableNvfKeymaps "ChatGPT" "<leader>ac";
      editWithInstructions = mkMappingOption config.vim.enableNvfKeymaps "[ChatGPT] Edit with instructions" "<leader>ae";
      grammarCorrection = mkMappingOption config.vim.enableNvfKeymaps "[ChatGPT] Grammar correction" "<leader>ag";
      translate = mkMappingOption config.vim.enableNvfKeymaps "[ChatGPT] Translate" "<leader>at";
      keyword = mkMappingOption config.vim.enableNvfKeymaps "[ChatGPT] Keywords" "<leader>ak";
      docstring = mkMappingOption config.vim.enableNvfKeymaps "[ChatGPT] Docstring" "<leader>ad";
      addTests = mkMappingOption config.vim.enableNvfKeymaps "[ChatGPT] Add tests" "<leader>aa";
      optimize = mkMappingOption config.vim.enableNvfKeymaps "[ChatGPT] Optimize code" "<leader>ao";
      summarize = mkMappingOption config.vim.enableNvfKeymaps "[ChatGPT] Summarize" "<leader>as";
      fixBugs = mkMappingOption config.vim.enableNvfKeymaps "[ChatGPT] Fix bugs" "<leader>af";
      explain = mkMappingOption config.vim.enableNvfKeymaps "[ChatGPT] Explain code" "<leader>ax";
      roxygenEdit = mkMappingOption config.vim.enableNvfKeymaps "[ChatGPT] Roxygen edit" "<leader>ar";
      readabilityanalysis = mkMappingOption config.vim.enableNvfKeymaps "[ChatGPT] Code reability analysis" "<leader>al";
    };
  };
}
