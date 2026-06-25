{lib, ...}: let
  inherit (lib.options) mkEnableOption mkOption;
  inherit
    (lib.types)
    nullOr
    oneOf
    enum
    attrsOf
    number
    int
    ;
  inherit (lib.nvim.types) mkPluginSetupOption;

  # Top-level targets only accepts `cmd` and `msg`, which is shorter, so we define that one
  # inline below. This is the accepted targets for ui2 messages when defining it as a table
  # or an attrset in Nix.
  msgTargetEnum = enum [
    "cmd"
    "msg"
    "pager"
  ];

  heightOption = target: default:
    mkOption {
      description = "Maximum height for the ${target} window";
      type = number;
      inherit default;
    };
in {
  options.vim.ui.ui2 = {
    enable = mkEnableOption "the Neovim 0.12+ experimental built-in UI overhaul";

    setupOpts = mkPluginSetupOption "ui2" {
      msg = {
        targets = mkOption {
          description = ''
            Default message target, either commandline or a separate window.
            Can alternatively specify different targets for different kinds of messages as an attrset.
            See [`:h ui-messages`](https://neovim.io/doc/user/api-ui-events/#ui-messages)
            for the different message types you can use in this configuration.
            Separating the message types also allows sending to a 'pager' output.
          '';
          type = nullOr (oneOf [
            (enum [
              "cmd"
              "msg"
            ])
            (attrsOf msgTargetEnum)
          ]);
          default = "cmd";
          example = {
            bufwrite = "cmd";
            quickfix = "msg";
          };
        };
        cmd = {
          height = heightOption "cmdline" 0.5;
        };
        dialog = {
          height = heightOption "dialog" 0.5;
        };
        msg = {
          height = heightOption "msg" 0.5;
          timeout = mkOption {
            description = "Time a message is visible in the message window";
            type = int;
            default = 4000;
            example = 1500;
          };
        };
        pager = {
          height = heightOption "pager" 1;
        };
      };
    };
  };
}
