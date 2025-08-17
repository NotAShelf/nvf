# Using DAGs {#ch-using-dags}

We conform to the NixOS options types for the most part, however, a noteworthy
addition for certain options is the
[**DAG (Directed acyclic graph)**](https://en.wikipedia.org/wiki/Directed_acyclic_graph)
type which is borrowed from home-manager's extended library. This type is most
used for topologically sorting strings. The DAG type allows the attribute set
entries to express dependency relations among themselves. This can, for example,
be used to control the order of configuration sections in your `luaConfigRC`.

The below section, mostly taken from the
[home-manager manual](https://raw.githubusercontent.com/nix-community/home-manager/master/docs/manual/writing-modules/types.md)
explains in more detail the overall usage logic of the DAG type.

## entryAnywhere {#sec-types-dag-entryAnywhere}

> `nvf.lib.nvim.dag.entryAnywhere (value: T) : DagEntry<T>`

Indicates that `value` can be placed anywhere within the DAG. This is also the
default for plain attribute set entries, that is

```nix
# For 'nvf' to be available in module's arguments,
# it needs to be inherited from imports in the modules array as:
# modules = [{ _module.args = { inherit nvf; }; } ...]; 
foo.bar = {
  a = nvf.lib.nvim.dag.entryAnywhere 0;
}
```

and

```nix
foo.bar = {
  a = 0;
}
```

are equivalent.

## entryAfter {#ch-types-dag-entryAfter}

> `nvf.lib.nvim.dag.entryAfter (afters: list string) (value: T) : DagEntry<T>`

Indicates that `value` must be placed _after_ each of the attribute names in the
given list. For example

```nix
foo.bar = {
  a = 0;
  b = nvf.lib.nvim.dag.entryAfter [ "a" ] 1;
}
```

would place `b` after `a` in the graph.

## entryBefore {#ch-types-dag-entryBefore}

> `nvf.lib.nvim.dag.entryBefore (befores: list string) (value: T) : DagEntry<T>`

Indicates that `value` must be placed _before_ each of the attribute names in
the given list. For example

```nix
foo.bar = {
  b = nvf.lib.nvim.dag.entryBefore [ "a" ] 1;
  a = 0;
}
```

would place `b` before `a` in the graph.

## entryBetween {#sec-types-dag-entryBetween}

> `nvf.lib.nvim.dag.entryBetween (befores: list string) (afters: list string) (value: T) : DagEntry<T>`

Indicates that `value` must be placed _before_ the attribute names in the first
list and _after_ the attribute names in the second list. For example

```nix
foo.bar = {
  a = 0;
  c = nvf.lib.nvim.dag.entryBetween [ "b" ] [ "a" ] 2;
  b = 1;
}
```

would place `c` before `b` and after `a` in the graph.

There are also a set of functions that generate a DAG from a list. These are
convenient when you just want to have a linear list of DAG entries, without
having to manually enter the relationship between each entry. Each of these
functions take a `tag` as argument and the DAG entries will be named
`${tag}-${index}`.

## entriesAnywhere {#sec-types-dag-entriesAnywhere}

> `nvf.lib.nvim.dag.entriesAnywhere (tag: string) (values: [T]) : Dag<T>`

Creates a DAG with the given values with each entry labeled using the given tag.
For example

```nix
foo.bar = nvf.lib.nvim.dag.entriesAnywhere "a" [ 0 1 ];
```

is equivalent to

```nix
foo.bar = {
  a-0 = 0;
  a-1 = nvf.lib.nvim.dag.entryAfter [ "a-0" ] 1;
}
```

## entriesAfter {#sec-types-dag-entriesAfter}

> `nvf.lib.nvim.dag.entriesAfter (tag: string) (afters: list string) (values: [T]) : Dag<T>`

Creates a DAG with the given values with each entry labeled using the given tag.
The list of values are placed are placed _after_ each of the attribute names in
`afters`. For example

```nix
foo.bar =
  { b = 0; } // nvf.lib.nvim.dag.entriesAfter "a" [ "b" ] [ 1 2 ];
```

is equivalent to

```nix
foo.bar = {
  b = 0;
  a-0 = nvf.lib.nvim.dag.entryAfter [ "b" ] 1;
  a-1 = nvf.lib.nvim.dag.entryAfter [ "a-0" ] 2;
}
```

## entriesBefore {#sec-types-dag-entriesBefore}

> `nvf.lib.nvim.dag.entriesBefore (tag: string) (befores: list string) (values: [T]) : Dag<T>`

Creates a DAG with the given values with each entry labeled using the given tag.
The list of values are placed _before_ each of the attribute names in `befores`.
For example

```nix
foo.bar =
  { b = 0; } // nvf.lib.nvim.dag.entriesBefore "a" [ "b" ] [ 1 2 ];
```

is equivalent to

```nix
foo.bar = {
  b = 0;
  a-0 = 1;
  a-1 = nvf.lib.nvim.dag.entryBetween [ "b" ] [ "a-0" ] 2;
}
```

## entriesBetween {#sec-types-dag-entriesBetween}

> `nvf.lib.nvim.dag.entriesBetween (tag: string) (befores: list string) (afters: list string) (values: [T]) : Dag<T>`

Creates a DAG with the given values with each entry labeled using the given tag.
The list of values are placed _before_ each of the attribute names in `befores`
and _after_ each of the attribute names in `afters`. For example

```nix
foo.bar =
  { b = 0; c = 3; } // nvf.lib.nvim.dag.entriesBetween "a" [ "b" ] [ "c" ] [ 1 2 ];
```

is equivalent to

```nix
foo.bar = {
  b = 0;
  c = 3;
  a-0 = nvf.lib.nvim.dag.entryAfter [ "c" ] 1;
  a-1 = nvf.lib.nvim.dag.entryBetween [ "b" ] [ "a-0" ] 2;
}
```
