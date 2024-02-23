{
  # TODO: give those section indicators
  # maybe using mkSection?
  wrapLuaConfig = {
    luaConfigBefore,
    luaConfig,
    luaConfigAfter,
  }: ''
    lua << EOF
    ${luaConfigBefore}
    ${luaConfig}
    ${luaConfigAfter}
    EOF
  '';
}
