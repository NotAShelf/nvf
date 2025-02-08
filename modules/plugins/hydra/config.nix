{
  config,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  cfg = config.vim.hydra;
in {
  config = mkIf cfg.enable {
    vim = {
      startPlugins = [];
      lazy.plugins.hydra = {
        package = "hydra-nvim";
        setupModule = "hydra";
        #inherit (cfg) setupOpts;
        setupOpts = {
          debug = false;
          exit = false;
          foreign_keys = null;
          color = "red";
          timeout = false;
          invoke_on_body = false;
          hint = {
            show_name = true;
            position = "bottom";
            offset = 0;
            float_opts = {};
          };
          on_enter = null;
          on_exit = null;
          on_key = null;
        };

        after = ''
          -- custom lua code to run after plugin is loaded
          print('multicursors loaded')
        '';

        event = ["DeferredUIEnter"];
        cmd = ["MCstart" "MCvisual" "MCclear" "MCpattern" "MCvisualPattern" "MCunderCursor"];
      };
      #keys = [
      #  (mkKeymap "n" mappings.mcStart "<cmd>MCstart<cr>" {desc = "Create a selection for selected text or word under the cursor [multicursors.nvim]";})
      #];
      # dependencies = [
      #   config.vim.lazy.plugins.hydra # hydra.nvim - Create custom submodes and menus
      # ];
    };
  };
}
