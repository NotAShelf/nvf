{
  testers,
  profiles,
  modules,
  ...
}:
testers.runNixOSTest {
  name = "nvf-home-manager-test";
  nodes.machine = {pkgs, ...}: {
    imports = [
      profiles.minimal
      modules.home-manager.nvf
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
        machine.succeed("runuser -l test -c 'echo hello > /home/test/input.txt'")
        machine.succeed("runuser -l test -c 'nvim --headless -c \"normal iworld\" -c \"wq\" /home/test/input.txt'")
        machine.succeed("grep 'worldhello' /home/test/input.txt")

      with subtest("Test nvf configuration"):
        machine.succeed("runuser -l test -c 'nvim --headless -c \"lua if vim.g.editorconfig == true then io.open(\\\"/home/test/config_result.txt\\\", \\\"w\\\"):write(\\\"true\\\"):close() end\" -c q'")
        machine.succeed("runuser -l test -c 'test -e /home/test/config_result.txt'")
        machine.succeed("runuser -l test -c 'cat /home/test/config_result.txt | grep true'")

      with subtest("Check for errors in startup messages"):
        machine.succeed("runuser -l test -c 'nvim --headless --startuptime /home/test/startup.log +q'")
        machine.succeed("runuser -l test -c 'grep -v -i \"error\" /home/test/startup.log | wc -l > /home/test/line_count.txt'")
        machine.succeed("test $(cat /home/test/line_count.txt) -gt 0")

      with subtest("Verify files in Neovim runtime path"):
        machine.succeed("runuser -l test -c 'nvim --cmd \"set rtp\" --headless -c q 2>&1 | grep \"/nix/store/\" > /home/test/vimruntime.txt'")
        machine.succeed("test -s /home/test/vimruntime.txt")

      with subtest("Verify extrapackages can be executed inside Neovim"):
        machine.succeed("runuser -l test -c 'nvim --headless -c \"silent !which lazygit > /home/test/lazygit_path.txt\" -c q'")
        machine.succeed("runuser -l test -c 'grep \"/nix/store/\" /home/test/lazygit_path.txt'")
    '';
}
