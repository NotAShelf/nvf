{
  pkgs,
  self,
  system,
  ...
}: {
  atlas-nvim = let
    neovim =
      (self.lib.neovimConfiguration {
        inherit pkgs;
        modules = [{vim.git.atlas-nvim.enable = true;}];
      }).neovim;
  in
    pkgs.runCommand "atlas-nvim-check" {nativeBuildInputs = [neovim];} ''
      export HOME="$TMPDIR"
      nvim --headless -c 'luafile ${pkgs.writeText "atlas-check.lua" ''
        local ok, err = pcall(function()
          assert(vim.fn.exists(":Atlas") == 2, "Atlas command is registered")
          assert(not package.loaded.atlas, "Atlas is lazy-loaded")
          vim.cmd.Atlas()
          assert(vim.wait(1000, function()
            for _, win in ipairs(vim.api.nvim_list_wins()) do
              local buf = vim.api.nvim_win_get_buf(win)
              for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(buf, -1, 0, -1, { details = true })) do
                for _, line in ipairs(mark[4].virt_lines or {}) do
                  for _, chunk in ipairs(line) do
                    if chunk[1]:find("Open pull requests", 1, true) then return true end
                  end
                end
              end
            end
            return false
          end), "Atlas command picker is visible")
          assert(vim.fn.executable("git") == 1, "git is available")
          assert(vim.fn.executable("curl") == 1, "curl is available")
          assert(vim.fn.executable("gh") == 1, "GitHub CLI is available")
          assert(vim.fn.maparg("<leader>ga", "n") ~= "", "Atlas mapping is registered")
        end)
        if not ok then print(err) end
        vim.cmd.cquit(ok and 0 or 1)
      ''}' -c 'cquit 1'
      touch "$out"
    '';

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
