{lib, ...}: let
  inherit (lib.options) mkOption literalExpression;
  inherit (lib.types) listOf str unspecified;
in {
  options = {
    assertions = mkOption {
      type = listOf unspecified;
      internal = true;
      default = [];
      example = literalExpression ''
        [
          {
            assertion = false;
            message = "you can't enable this for that reason";
          }
        ]
      '';
    };

    warnings = mkOption {
      internal = true;
      default = [];
      type = listOf str;
      example = ["The `foo' service is deprecated and will go away soon!"];
      description = ''
        This option allows modules to show warnings to users during
        the evaluation of the system configuration.
      '';
    };
  };
}
