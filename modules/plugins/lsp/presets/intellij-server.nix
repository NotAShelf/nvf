{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkLspPresetEnableOption;
  inherit (lib.meta) getExe;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.lsp.presets.intellij-server;
in {
  options.vim.lsp.presets.intellij-server = {
    enable = mkLspPresetEnableOption {
      option = "intellij-server";
      display = "JetBrains IntelliJ IDEA";
      extra = ''
        By using this preset you accept the JetBrains IntelliJ IDEA LSP EULA.
        This LSP is currently experimental and thus only has limited features.

        > [!IMPORTANT]
        > This LSP currently has no login requirements during its experimental phase,
        > but will require a valid license at the time where it goes stable.
      '';
    };
  };
  # TODO: Add support for the following custom commands in the future:
  # - :IntellijServer decompile
  # - :IntellijServer workspace reload
  # - :IntellijServer workspace export
  # - :IntellijServer workspace cache clear
  # - :IntellijServer login
  # - :IntellijServer logout

  config = mkIf cfg.enable {
    vim.lsp.servers.intellij-server = {
      enable = true;
      cmd = [
        (getExe (pkgs.symlinkJoin {
          name = "intellij-server-wrapper";
          paths = [inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.intellij-server];
          meta.mainProgram = "intellij-server";
          buildInputs = [pkgs.makeBinaryWrapper];
          postBuild = ''
            # Without package manager it can't even resolve builtin symbols like `String`
            wrapProgram $out/bin/intellij-server \
              --prefix PATH : ${pkgs.maven}/bin \
              --prefix PATH : ${pkgs.gradle}/bin
          '';
        }))
        "--stdio"
        "--data-sharing=none"
        "--region=not_set"
      ];
      root_markers = [
        ".idea"
        "pom.xml"
        "build.gradle"
        "build.gradle.kts"
        "settings.gradle"
        "settings.gradle.kts"
        ".git"
      ];
      init_options = {
        # Required for resolution of builtin symbols
        defaultSdk = "${pkgs.jdk25}/lib/openjdk";
        # For usage the EULA needs to be accepted.
        eulaHash = mkLuaInline ''
          (function()
            local file = io.open("${inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.intellij-server}/EULA.txt", "rb")
            local hash = vim.fn.sha256(file:read("*a"))
            file:close()
            return hash:sub(1, 16)
          end)()
        '';
      };
    };
  };
}
