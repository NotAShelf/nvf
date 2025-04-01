{
  testers,
  nixosModules,
  profiles,
  ...
}:
testers.runNixOSTest {
  name = "nvf-nixos-test";
  nodes.machine = {pkgs, ...}: {
    imports = [
      profiles.minimal
      nixosModules.nvf
    ];

    programs.nvf = {
      enable = true;

      settings.vim = {
        viAlias = true;
        vimAlias = true;

        globals = {
          editorconfig = true;
        };

        extraPackages = [pkgs.lazygit];
      };
    };
  };

  testScript =
    # python
    ''
      machine.start()
      machine.wait_for_unit("multi-user.target")

      with subtest("Verify that Neovim can be run by the test user and displays its version"):
        machine.succeed("runuser -l test -c 'nvim --version'")

      with subtest("Launch Neovim and immediately quit to verify it starts correctly"):
        machine.succeed("runuser -l test -c 'nvim -c q'")

      with subtest("Create a test file and open it with Neovim"):
        machine.succeed("runuser -l test -c 'echo \"test content\" > /home/test/testfile.txt'")
        machine.succeed("runuser -l test -c 'nvim -c \"wq\" /home/test/testfile.txt'")

      with subtest("Verify the file was edited and saved correctly"):
        machine.succeed("grep 'test content' /home/test/testfile.txt")

      with subtest("Run specific Neovim commands and verify the output"):
        machine.succeed("runuser -l test -c 'nvim --headless +\\\":echo \\\"hello, world!\\\"\\\" +q > /home/test/output.txt'")
        machine.succeed("grep 'hello, world!' /home/test/output.txt")

      with subtest("Test nvf-print-config-path commands"):
        machine.succeed("runuser -l test -c 'nvf-print-config | grep \"vim.g.editorconfig = true\"'")
        machine.succeed("runuser -l test -c 'nvf-print-config-path | grep /path/to/nix/store/config'")

      with subtest("Check for errors in startup messages"):
        machine.succeed("runuser -l test -c 'nvim --headless --startuptime /home/test/startup.log +q'")
        machine.fail("grep -i 'error' /home/test/startup.log")

      with subtest("Verify files in Neovim PATH to test extrapackages API"):
        machine.succeed("runuser -l test -c 'nvim --headless +\\\":echo $VIMRUNTIME\\\" +q | grep /nix/store/'")

      with subtest("Verify extrapackages can be executed inside Neovim"):
        machine.succeed("runuser -l test -c 'nvim --headless +\\\":!lazygit --version\\\" +q'")
    '';
}
