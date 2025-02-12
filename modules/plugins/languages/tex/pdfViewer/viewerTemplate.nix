# This function acts as a template for creating new pdf viewers.
# It enforces providing all the parameters required for creating
# a new pdf viewer for it to be able to work in the existing code.
#
# The first layer requirements are as follows:
{
  # This is the name of the pdf viewer, it will only be used internally and
  # MUST match the <name>.nix file that the pdf viewer is implemented in.
  name,
  #
  # Module attribute set. This is the attribute set that the module that is
  # defining a pdf viewer is passed as its input.
  moduleInheritancePackage,
  #
  # These are the standard options for the pdf viewer just like creating any
  # other module. Some options are required and are described below but
  # it will also accept any other options that are provided to it.
  options,
  #
  # These are the command line arguments that will accompany the executable
  # when the view command is called.
  # This is a function that will take in the cfg of its own pdf viewer.
  # i.e. it will be called as "args cfg.pdfViewer.${name}"
  argsFunction,
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
  #
  # Set the cfg of the viewer itself
  viewerCfg = cfg.pdfViewer.${name};
in {
  # These are the options for the pdf viewer. It will accept any options
  # provided to it but some options are mandatory:
  options.vim.languages.tex.pdfViewer.${name} = ({
      # The enable option. This one is self explanatory.
      enable,
      #
      # This is the package option for the pdf viewer.
      package,
      #
      # This is the executable that will be used to call the pdf viewer.
      # It, along with package will result in:
      # "<package_path>/bin/<executable>"
      executable,
      #
      # Any other options provided are accepted.
      ...
    } @ opts:
      opts)
  options;

  # Check that the language and this pdf viewer have been enabled before making
  # any config.
  config = mkIf (cfg.enable && viewerCfg.enable) {
    vim.languages.tex.pdfViewer = {
      inherit name;
      inherit (viewerCfg) package executable;
      args = argsFunction viewerCfg;
    };
  };
}
