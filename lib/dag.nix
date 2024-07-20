# From home-manager: https://github.com/nix-community/home-manager/blob/master/modules/lib/dag.nix
# A generalization of Nixpkgs's `strings-with-deps.nix`.
#
# The main differences from the Nixpkgs version are
#
#  - not specific to strings, i.e., any payload is OK,
#
#  - the addition of the function `entryBefore` indicating a "wanted
#    by" relationship.
{lib}: let
  inherit (builtins) isAttrs attrValues attrNames elem all head tail length toJSON isString;
  inherit (lib.attrsets) filterAttrs mapAttrs;
  inherit (lib.lists) toposort;
  inherit (lib.nvim.dag) empty isEntry entryBetween entryAfter entriesBetween entryAnywhere topoSort;
in {
  empty = {};

  isEntry = e: e ? data && e ? after && e ? before;
  isDag = dag:
    isAttrs dag && all isEntry (attrValues dag);

  /*
  Takes an attribute set containing entries built by entryAnywhere,
  entryAfter, and entryBefore to a topologically sorted list of
  entries.

  Internally this function uses the `toposort` function in
  `<nixpkgs/lib/lists.nix>` and its value is accordingly.

  Specifically, the result on success is

     { result = [ { name = ?; data = ?; } … ] }

  For example

     nix-repl> topoSort {
                 a = entryAnywhere "1";
                 b = entryAfter [ "a" "c" ] "2";
                 c = entryBefore [ "d" ] "3";
                 d = entryBefore [ "e" ] "4";
                 e = entryAnywhere "5";
               } == {
                 result = [
                   { data = "1"; name = "a"; }
                   { data = "3"; name = "c"; }
                   { data = "2"; name = "b"; }
                   { data = "4"; name = "d"; }
                   { data = "5"; name = "e"; }
                 ];
               }
     true

  And the result on error is

     {
       cycle = [ { after = ?; name = ?; data = ? } … ];
       loops = [ { after = ?; name = ?; data = ? } … ];
     }

  For example

     nix-repl> topoSort {
                 a = entryAnywhere "1";
                 b = entryAfter [ "a" "c" ] "2";
                 c = entryAfter [ "d" ] "3";
                 d = entryAfter [ "b" ] "4";
                 e = entryAnywhere "5";
               } == {
                 cycle = [
                   { after = [ "a" "c" ]; data = "2"; name = "b"; }
                   { after = [ "d" ]; data = "3"; name = "c"; }
                   { after = [ "b" ]; data = "4"; name = "d"; }
                 ];
                 loops = [
                   { after = [ "a" "c" ]; data = "2"; name = "b"; }
                 ];
               }
     true
  */
  topoSort = dag: let
    dagBefore = dag: name:
      attrNames
      (filterAttrs (_n: v: elem name v.before) dag);
    normalizedDag =
      mapAttrs (n: v: {
        name = n;
        inherit (v) data;
        after = v.after ++ dagBefore dag n;
      })
      dag;
    before = a: b: elem a.name b.after;
    sorted = toposort before (attrValues normalizedDag);
  in
    if sorted ? result
    then {
      result = map (v: {inherit (v) name data;}) sorted.result;
    }
    else sorted;

  # Applies a function to each element of the given DAG.
  map = f: mapAttrs (n: v: v // {data = f n v.data;});

  entryBetween = before: after: data: {inherit data before after;};

  # Create a DAG entry with no particular dependency information.
  entryAnywhere = entryBetween [] [];

  entryAfter = entryBetween [];
  entryBefore = before: entryBetween before [];

  # Given a list of entries, this function places them in order within the DAG.
  # Each entry is labeled "${tag}-${entry index}" and other DAG entries can be
  # added with 'before' or 'after' referring these indexed entries.
  #
  # The entries as a whole can be given a relation to other DAG nodes. All
  # generated nodes are then placed before or after those dependencies.
  entriesBetween = tag: let
    go = i: before: after: entries: let
      name = "${tag}-${toString i}";
    in
      if entries == []
      then empty
      else if length entries == 1
      then {
        "${name}" = entryBetween before after (head entries);
      }
      else
        {
          "${name}" = entryAfter after (head entries);
        }
        // go (i + 1) before [name] (tail entries);
  in
    go 0;

  entriesAnywhere = tag: entriesBetween tag [] [];
  entriesAfter = tag: entriesBetween tag [];
  entriesBefore = tag: before: entriesBetween tag before [];

  # mkLuarcSection and mkVimrcSection take a section DAG
  # and return a string containing a comment to identify
  # the section, and the data contained within the section
  #
  # all operations are done without any modifications
  # to the inputted section data
  mkLuarcSection = section: ''
    -- SECTION: ${section.name}
    ${section.data}
  '';

  resolveDag = {
    name,
    dag,
    mapResult,
  }: let
    # When the value is a string, default it to dag.entryAnywhere
    finalDag = mapAttrs (_: value:
      if isString value
      then entryAnywhere value
      else value)
    dag;
    sortedDag = topoSort finalDag;
    result =
      if sortedDag ? result
      then mapResult sortedDag.result
      else abort ("Dependency cycle in ${name}: " + toJSON sortedDag);
  in
    result;
}
