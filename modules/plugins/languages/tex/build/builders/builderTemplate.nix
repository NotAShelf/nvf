# This function acts as a template for creating new builders.
# It enforces providing all the parameters required for creating
# a new builder for it to be able to work in the existing code.
#
# The first layer requirements are as follows:
{
  # This is the name of the builder, it will only be used internally and
  # should match the <name>.nix file that the builder is implemented in.
  name,
  #
  # Module attribute set. This is the attribute set that the module that is
  # defining a builder is passed as its input.
  moduleInheritancePackage,
  #
  # These are the standard options for the builder just like creating any
  # other module. Some options are required and are described below but
  # it will also accept any other options that are provided to it.
  options,
  #
  # These are the command line arguments that will accompany the executable
  # when the build command is called.
  # This is a function that will take in the cfg of its own builder.
  # i.e. will be called as "args cfg.build.builders.${name}"
  args,
  ...
}: let
  # Inherit the necessary variables available to any module.
  inherit (moduleInheritancePackage) lib config;
  #
  # Inherit other useful functions.
  inherit (lib.modules) mkIf;
  #
  # Set the cfg variable
  cfg = config.vim.languages.tex;
in {
  # These are the options for the builder. It will accept any options
  # provided to it but some options are mandatory:
  options.vim.languages.tex.build.builders.${name} = ({
      # The enable option. This one is self explanatory.
      enable,
      #
      # This is the package option for the builder.
      package,
      #
      # This is the executable that will be used to call the builder.
      # It, along with package will result in:
      # "<package_path>/bin/<executable>"
      executable,
      #
      # Any other options provided are accepted.
      ...
    } @ opts:
      opts)
  options;

  # Check that the language and this builder have been enabled
  # before making any config.
  config = mkIf (cfg.enable && cfg.build.builders.${name}.enable) {
    vim.languages.tex.build.builder = {
      inherit name;
      package = cfg.build.builders.${name}.package;
      executable = cfg.build.builders.${name}.executable;
      args = args cfg.build.builders.${name};
    };
  };
}
