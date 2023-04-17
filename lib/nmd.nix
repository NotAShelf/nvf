# Copied from nmd master: https://gitlab.com/rycee/nmd/-/blob/master/default.nix?ref_type=heads
# Allows asciiDoc in options. It is easier to copy & keep updated then figure out how to pass the nmd input
# along to user modules
{
  # Indicates that the given text should be interpreted as AsciiDoc markup.
  asciiDoc = text: {
    _type = "asciiDoc";
    inherit text;
  };

  # Indicates that the given text should be interpreted as AsciiDoc markup and
  # used in a literal context.
  literalAsciiDoc = text: {
    _type = "literalAsciiDoc";
    inherit text;
  };
}
