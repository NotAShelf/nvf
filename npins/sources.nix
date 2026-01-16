{
  lib,
  fetchurl,
  fetchgit,
  fetchzip,
}:
builtins.mapAttrs
(
  name: spec: let
    mayOverride = name: path: let
      envVarName = "NPINS_OVERRIDE_${saneName}";
      saneName = builtins.concatStringsSep "_" (
        builtins.concatLists (
          builtins.filter (x: builtins.isList x && x != [""]) (builtins.split "([a-zA-Z0-9]*)" name)
        )
      );
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

    path =
      rec {
        GitRelease = Git;
        Channel = Tarball;

        Git =
          if spec.url != null && !spec.submodules
          then Tarball
          else
            fetchgit (
              let
                repo = spec.repository;
                url =
                  {
                    Git = repo.url;
                    GitHub = "https://github.com/${repo.owner}/${repo.repo}.git";
                    GitLab = "${repo.server}/${repo.repo_path}.git";
                    Forgejo = "${repo.server}/${repo.owner}/${repo.repo}.git";
                  }
                    .${
                    repo.type
                  } or (throw "Unrecognized repository type ${repo.type}");
              in {
                name = let
                  matched = builtins.match "^.*/([^/]*)(\\.git)?$" url;
                  appendShort =
                    if (builtins.match "[a-f0-9]*" spec.revision) != null
                    then "-${builtins.substring 0 7 spec.revision}"
                    else "";
                in "${
                  if matched == null
                  then "source"
                  else builtins.head matched
                }${appendShort}";
                inherit url;

                rev = spec.revision;
                inherit (spec) hash;
                fetchSubmodules = spec.submodules;
              }
            );

        PyPi = fetchurl {
          inherit (spec) url hash;
        };

        Tarball = fetchzip {
          inherit (spec) url hash;
          extension = "tar";
        };
      }
        .${
        spec.type
      } or (builtins.throw "Unknown source type ${spec.type}");

    version =
      if spec ? revision
      then builtins.substring 0 8 spec.revision
      else "0";
  in
    spec
    // {
      name = "${name}-${version}";
      pname = name;
      inherit version;
      outPath =
        (
          # Override logic won't do anything if we're in pure eval
          if builtins ? currentSystem
          then mayOverride name path
          else path
        ).overrideAttrs
        {
          pname = name;
          name = "${name}-${version}";
          inherit version;
        };
    }
)
(
  let
    json = lib.importJSON ./sources.json;
  in
    assert lib.assertMsg (json.version == 7) "Unsupported format version ${toString json.version} in sources.json. Try running `npins upgrade`";
      json.pins
)
