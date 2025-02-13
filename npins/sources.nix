# Based off of:
# https://github.com/NixOS/nixpkgs/blob/776c3bee4769c616479393aeefceefeda16b6fcb/pkgs/tools/nix/npins/source.nix
{
  lib,
  fetchurl,
  fetchgit,
  fetchzip,
}:
builtins.mapAttrs
(
  _: let
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
      hash,
      ...
    } @ attrs:
      assert repository ? type;
        if url != null
        then getZip attrs
        else
          assert repository.type == "Git"; let
            urlToName = url: rev: let
              matched = builtins.match "^.*/([^/]*)(\\.git)?$" repository.url;
              short = builtins.substring 0 7 rev;
              appendShort =
                if (builtins.match "[a-f0-9]*" rev) != null
                then "-${short}"
                else "";
            in "${
              if matched == null
              then "source"
              else builtins.head matched
            }${appendShort}";
            name = urlToName repository.url revision;
          in
            fetchgit {
              inherit name;
              inherit (repository) url;
              rev = revision;
              sha256 = hash;
            };

    mkPyPiSource = {
      url,
      hash,
      ...
    }:
      fetchurl {
        inherit url;
        sha256 = hash;
      };
  in
    spec:
      assert spec ? type; let
        func =
          {
            Git = mkGitSource;
            GitRelease = mkGitSource;
            PyPi = mkPyPiSource;
            Channel = getZip;
          }
          .${spec.type}
          or (builtins.throw "Unknown source type ${spec.type}");
      in
        spec // {outPath = func spec;}
)
(
  let
    json = lib.importJSON ./sources.json;
  in
    assert lib.assertMsg (json.version == 3) "Npins version mismatch!";
      json.pins
)
