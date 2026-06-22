{
  perSystem = {
    config,
    pkgs,
    ...
  }: {
    checks = {
      nvf-nix = pkgs.testers.runNixOSTest {
        name = "nvf-nix";
        nodes.machine = {
          virtualisation.graphics = false;
          virtualisation.memorySize = 512;
          environment.systemPackages = [config.packages.nix];
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
          environment.systemPackages = [config.packages.maximal];
        };

        testScript = ''
          machine.wait_for_unit("multi-user.target")
          machine.succeed("nvim --headless +q")
          machine.succeed("nvim --headless -c 'lua print(1)' +q")
        '';
      };
    };
  };
}
