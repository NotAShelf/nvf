{
  inputs,
  nixosTest,
  homeManagerModules,
  testProfile,
  ...
}:
nixosTest {
  name = "home-manager-test";
  skipLint = true;

  nodes.machine = {
    imports = [
      testProfile
      inputs.home-manager.nixosModules.home-manager
    ];

    config = {
      home-manager = {
        sharedModules = [
          homeManagerModules.nvf
        ];

        users.test = {
          home.stateVersion = "24.05";
          programs.nvf.enable = true;
        };
      };
    };
  };

  testScript = "";
}
