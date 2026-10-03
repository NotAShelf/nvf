{
  lib,
  config,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.nvim.types) mkDapPresetEnableOption;
  inherit (lib.generators) mkLuaInline;

  cfg = config.vim.debugger.nvim-dap.presets.intellij-server;

  host = "127.0.0.1";
  port = 43849;
in {
  options.vim.debugger.nvim-dap.presets.intellij-server = {
    enable = mkDapPresetEnableOption {
      option = "intellij-server";
      display = "JetBrains IntelliJ IDEA";
      extra = ''
        This DAP doesn't work standalone and requires
        {option}`vim.lsp.presets.intellij-server.enable`
        to work as expected.
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = config.vim.lsp.presets.intellij-server.enable;
        message = ''
          The IntelliJ IDEA DAP, requires the IntelliJ IDEA LSP to function.
        '';
      }
    ];

    vim.debugger.nvim-dap.adapters = {
      intellij-server = mkLuaInline ''
        function(on_config, config, parent)
          local SERVER_NAME = "intellij-server"

          local function error(msg)
            vim.notify("intellij-server DAP: " .. msg, vim.log.levels.ERROR)
          end

          local LSP = {}

          function LSP.command(command, args, callback)
            local client = vim.lsp.get_clients({ name = SERVER_NAME })[1]
            if not client then
              callback(SERVER_NAME .. " LSP not running", nil)
              return
            end
            client:request("workspace/executeCommand", { command = command, arguments = args }, function(err, res)
              vim.schedule(function()
                callback(err, res)
              end)
            end)
          end

          function LSP.resolve_field(cfg, field, command, response_field, uri)
            return function(next)
              if cfg[field] then
                return next()
              end
              LSP.command(command, { { uri = uri } }, function(err, res)
                if err then
                  error(command .. " failed: " .. tostring(err))
                elseif res and res[response_field] then
                  cfg[field] = res[response_field]
                end
                next()
              end)
            end
          end

          function LSP.enrich_config(cfg, on_cfg)
            if cfg.request ~= "launch" then
              return on_cfg(cfg)
            end
            if not cfg.mainClass then
              error("launch requires `mainClass` in the configuration; aborting launch")
              return
            end

            LSP.command("intellij.java.resolveClassDocument", { { fqn = cfg.mainClass } }, function(err, res)
              if err or not res or not res.uri then
                error("resolveClassDocument failed, aborting launch: " .. tostring(err))
                return
              end

              local steps = {
                LSP.resolve_field(cfg, "classPaths", "intellij.java.resolveClasspath",        "classpath",        res.uri),
                LSP.resolve_field(cfg, "cwd",        "intellij.java.resolveWorkingDirectory", "workingDirectory", res.uri),
                LSP.resolve_field(cfg, "javaExec",   "intellij.java.resolveJavaExecutable",   "javaExec",         res.uri),
              }
              local step_index = 0
              local function run_next_step()
                step_index = step_index + 1
                local step = steps[step_index]
                if not step then
                  return on_cfg(cfg)
                end
                step(run_next_step)
              end
              run_next_step()
            end)
          end

          local BRIDGE
          BRIDGE = {
            pump = function(a, b)
              a:read_start(function(err, data)
                if err or not data then
                  pcall(a.close, a)
                  pcall(b.close, b)
                  return
                end
                if not b:write(data) then
                  pcall(a.close, a)
                  pcall(b.close, b)
                end
              end)
            end,

            accept = function(on_client)
              local listener = vim.uv.new_tcp()
              local ok, bind_err = pcall(function()
                listener:bind("${host}", ${toString port})
              end)
              if not ok then
                error("bridge bind error: " .. tostring(bind_err))
                return
              end
              listener:listen(128, function(listen_err)
                vim.schedule(function()
                  if listen_err then
                    error("bridge listen error: " .. tostring(listen_err))
                    return pcall(listener.close, listener)
                  end
                  local client_sock = vim.uv.new_tcp()
                  listener:accept(client_sock)
                  pcall(listener.close, listener)
                  on_client(client_sock)
                end)
              end)
            end,

            relay = function(client_sock)
              LSP.command("start_debug_server", {}, function(start_err, port)
                if start_err or not port then
                  error("start_debug_server failed: " .. tostring(start_err))
                  return pcall(client_sock.close, client_sock)
                end

                local server_sock = vim.uv.new_tcp()
                server_sock:connect("${host}", tonumber(port), function(connect_err)
                  vim.schedule(function()
                    if connect_err then
                      error("connect to " .. tostring(port) .. " failed: " .. tostring(connect_err))
                      return pcall(client_sock.close, client_sock)
                    end
                    BRIDGE.pump(client_sock, server_sock)
                    BRIDGE.pump(server_sock, client_sock)

                    local dap = require("dap")
                    local key = "intellij-server-bridge"
                    local function cleanup()
                      pcall(client_sock.close, client_sock)
                      pcall(server_sock.close, server_sock)
                      return true
                    end
                    dap.listeners.before.event_terminated[key] = cleanup
                    dap.listeners.before.event_exited[key] = cleanup
                  end)
                end)
              end)
            end,
          }

          BRIDGE.accept(BRIDGE.relay)

          on_config({
            type = "server",
            host = "${host}",
            port = ${toString port},
            id = "intellij_debugger",
            enrich_config = LSP.enrich_config,
          })
        end
      '';
    };
  };
}
