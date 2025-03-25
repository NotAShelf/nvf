{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf mkMerge;
  inherit (lib.nvim.binds) addDescriptionsToMappings mkSetBinding mkSetLuaBinding;

  self = import ./codecompanion-nvim.nix {inherit lib;};
  cfg = config.vim.assistant.codecompanion-nvim;

  mappingDefinitions = self.options.vim.assistant.codecompanion-nvim.mappings;
  mappings = addDescriptionsToMappings cfg.mappings mappingDefinitions;
  maps = mkMerge [
    (mkSetBinding mappings.inlineAssistant.open "<cmd>CodeCompanion<CR>")
    (mkSetBinding mappings.chat.open "<cmd>CodeCompanionChat<CR>")
    (mkSetBinding mappings.chat.toggle "<cmd>CodeCompanionChat Toggle<CR>")
    (mkSetBinding mappings.actions.open "<cmd>CodeCompanionActions<CR>")
    (mkSetLuaBinding mappings.command.open "function() vim.fn.feedkeys(\":CodeCompanionCmd \") end")
  ];
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [
        "plenary-nvim"
      ];

      lazy.plugins = {
        codecompanion-nvim = {
          package = "codecompanion-nvim";
          setupModule = "codecompanion";
          inherit (cfg) setupOpts;
        };
      };

      maps = {
        visual = mkMerge [
          (mkSetBinding mappings.chat.addToChatBuffer "<cmd>CodeCompanionChat Add<CR>")
          maps
        ];
        normal = maps;
      };

      treesitter.enable = true;
    };
  };
}
