{lib}: {
  mkBool = value: description:
    lib.mkOption {
      type = lib.types.bool;
      default = value;
      inherit description;
    };
}
