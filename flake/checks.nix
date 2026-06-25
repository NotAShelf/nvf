{
  pkgs,
  self,
  system,
  ...
}: {
  nvf-nix = pkgs.testers.runNixOSTest {
    name = "nvf-nix";
    nodes.machine = {
      virtualisation.graphics = false;
      virtualisation.memorySize = 512;
      environment.systemPackages = [self.packages.${system}.nix];
    };

    testScript = ''
      machine.wait_for_unit("multi-user.target")
      machine.succeed("nvim --headless +q")
      machine.succeed("nvim --headless -c 'lua print(1)' +q")
    '';
  };

  nvf-maximal = pkgs.testers.nixosTest {
    name = "nvf-maximal";
    nodes.machine = {
      virtualisation.graphics = false;
      virtualisation.memorySize = 512;
      environment.systemPackages = [self.packages.${system}.maximal];
    };

    testScript = ''
      machine.wait_for_unit("multi-user.target")
      machine.succeed("nvim --headless +q")
      machine.succeed("nvim --headless -c 'lua print(1)' +q")
    '';
  };
}
