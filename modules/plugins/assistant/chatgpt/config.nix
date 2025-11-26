{
  config,
  lib,
  options,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.binds) addDescriptionsToMappings mkSetBinding;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.assistant.chatgpt;

  mappingDefinitions = options.vim.assistant.chatgpt.mappings;
  mappings = addDescriptionsToMappings cfg.mappings mappingDefinitions;
  maps = mkMerge [
    (mkSetBinding mappings.editWithInstructions "<cmd>ChatGPTEditWithInstruction<CR>")
    (mkSetBinding mappings.grammarCorrection "<cmd>ChatGPTRun grammar_correction<CR>")
    (mkSetBinding mappings.translate "<cmd>ChatGPTRun translate<CR>")
    (mkSetBinding mappings.keyword "<cmd>ChatGPTRun keywords<CR>")
    (mkSetBinding mappings.docstring "<cmd>ChatGPTRun docstring<CR>")
    (mkSetBinding mappings.addTests "<cmd>ChatGPTRun add_tests<CR>")
    (mkSetBinding mappings.optimize "<cmd>ChatGPTRun optimize_code<CR>")
    (mkSetBinding mappings.summarize "<cmd>ChatGPTRun summarize<CR>")
    (mkSetBinding mappings.fixBugs "<cmd>ChatGPTRun fix_bugs<CR>")
    (mkSetBinding mappings.explain "<cmd>ChatGPTRun explain_code<CR>")
    (mkSetBinding mappings.roxygenEdit "<cmd>ChatGPTRun roxygen_edit<CR>")
    (mkSetBinding mappings.readabilityanalysis "<cmd>ChatGPTRun code_readability_analysis<CR>")
  ];
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [
        "chatgpt-nvim"

        # Dependencies
        "nui-nvim"
        "plenary-nvim"
      ];

      # ChatGPT.nvim explicitly depends on Telescope.
      telescope.enable = true;

      pluginRC.chagpt = entryAnywhere ''
        require("chatgpt").setup(${toLuaObject cfg.setupOpts})
      '';

      maps = {
        visual = maps;
        normal = mkMerge [
          (mkSetBinding mappings.chatGpt "<cmd>ChatGPT<CR>")
          maps
        ];
      };
    };
  };
}
