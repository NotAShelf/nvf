{
  config,
  lib,
  options,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.dag) entryAnywhere;
  inherit (lib.nvim.binds) mkKeymap;
  inherit (lib.nvim.lua) toLuaObject;

  cfg = config.vim.assistant.chatgpt;

  inherit (options.vim.assistant.chatgpt) mappings;
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

      keymaps = [
        (mkKeymap ["n" "v"] cfg.mappings.editWithInstructions "<cmd>ChatGPTEditWithInstruction<CR>" {desc = mappings.editWithInstructions.description;})
        (mkKeymap ["n" "v"] cfg.mappings.grammarCorrection "<cmd>ChatGPTRun grammar_correction<CR>" {desc = mappings.grammarCorrection.description;})
        (mkKeymap ["n" "v"] cfg.mappings.translate "<cmd>ChatGPTRun translate<CR>" {desc = mappings.translate.description;})
        (mkKeymap ["n" "v"] cfg.mappings.keyword "<cmd>ChatGPTRun keywords<CR>" {desc = mappings.keyword.description;})
        (mkKeymap ["n" "v"] cfg.mappings.docstring "<cmd>ChatGPTRun docstring<CR>" {desc = mappings.docstring.description;})
        (mkKeymap ["n" "v"] cfg.mappings.addTests "<cmd>ChatGPTRun add_tests<CR>" {desc = mappings.addTests.description;})
        (mkKeymap ["n" "v"] cfg.mappings.optimize "<cmd>ChatGPTRun optimize_code<CR>" {desc = mappings.optimize.description;})
        (mkKeymap ["n" "v"] cfg.mappings.summarize "<cmd>ChatGPTRun summarize<CR>" {desc = mappings.summarize.description;})
        (mkKeymap ["n" "v"] cfg.mappings.fixBugs "<cmd>ChatGPTRun fix_bugs<CR>" {desc = mappings.fixBugs.description;})
        (mkKeymap ["n" "v"] cfg.mappings.explain "<cmd>ChatGPTRun explain_code<CR>" {desc = mappings.explain.description;})
        (mkKeymap ["n" "v"] cfg.mappings.roxygenEdit "<cmd>ChatGPTRun roxygen_edit<CR>" {desc = mappings.roxygenEdit.description;})
        (mkKeymap ["n" "v"] cfg.mappings.readabilityanalysis "<cmd>ChatGPTRun code_readability_analysis<CR>" {desc = mappings.readabilityanalysis.description;})
        (mkKeymap "n" cfg.mappings.chatGpt "<cmd>ChatGPT<CR>" {desc = mappings.chatGpt.description;})
      ];
    };
  };
}
