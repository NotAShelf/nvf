{
  lib,
  fetchurl,
  fetchgit,
  fetchzip,
}:
builtins.mapAttrs
(
  name: let
    getUrl = {
      url,
      hash,
      ...
    }:
      fetchurl {
        inherit url;
        sha256 = hash;
      };
    getZip = {
      url,
      hash,
      ...
    }:
      fetchzip {
        inherit url;
        sha256 = hash;
        extension = "tar";
      };
    mkGitSource = {
      repository,
      revision,
      url ? null,
      submodules,
      hash,
      ...
    } @ attrs:
      assert repository ? type;
        if url != null && !submodules
        then getZip attrs
        else
          assert repository.type == "Git"; let
            url' =
              if repository.type == "Git"
              then repository.url
              else if repository.type == "GitHub"
              then "https://github.com/${repository.owner}/${repository.repo}.git"
              else if repository.type == "GitLab"
              then "${repository.server}/${repository.repo_path}.git"
              else throw "Unrecognized repository type ${repository.type}";

            name = let
              matched = builtins.match "^.*/([^/]*)(\\.git)?$" url';
              short = builtins.substring 0 7 revision;
              appendShort =
                if (builtins.match "[a-f0-9]*" revision) != null
                then "-${short}"
                else "";
            in "${
              if matched == null
              then "source"
              else builtins.head matched
            }${appendShort}";
          in
            fetchgit {
              inherit name;
              url = url';
              rev = revision;
              sha256 = hash;
              fetchSubmodules = submodules;
            };
  in
    spec:
      assert spec ? type; let
        mayOverride = path: let
          envVarName = "NPINS_OVERRIDE_${saneName}";
          saneName = lib.stringAsChars (c:
            if (builtins.match "[a-zA-Z0-9]" c) == null
            then "_"
            else c)
          name;
          ersatz = builtins.getEnv envVarName;
        in
          if ersatz == ""
          then path
          else
            # this turns the string into an actual Nix path (for both absolute and
            # relative paths)
            builtins.trace "Overriding path of \"${name}\" with \"${ersatz}\" due to set \"${envVarName}\"" (
              if builtins.substring 0 1 ersatz == "/"
              then /. + ersatz
              else /. + builtins.getEnv "PWD" + "/${ersatz}"
            );
        func =
          {
            Git = mkGitSource;
            GitRelease = mkGitSource;
            PyPi = getUrl;
            Channel = getZip;
            Tarball = getUrl;
          }
          .${
            spec.type
          }
          or (builtins.throw "Unknown source type ${spec.type}");
      in
        spec // {outPath = mayOverride (func spec);}
)
(
  let
    json = lib.importJSON ./sources.json;
  in
    assert lib.assertMsg (json.version == 5) "Npins version mismatch!";
      json.pins
)
