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

> `lib.dag.entryAnywhere (value: T) : DagEntry<T>`

Indicates that `value` can be placed anywhere within the DAG. This is also the
default for plain attribute set entries, that is

```nix
foo.bar = {
  a = lib.dag.entryAnywhere 0;
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

> `lib.dag.entryAfter (afters: list string) (value: T) : DagEntry<T>`

Indicates that `value` must be placed _after_ each of the attribute names in the
given list. For example

```nix
foo.bar = {
  a = 0;
  b = lib.dag.entryAfter [ "a" ] 1;
}
```

would place `b` after `a` in the graph.

## entryBefore {#ch-types-dag-entryBefore}

> `lib.dag.entryBefore (befores: list string) (value: T) : DagEntry<T>`

Indicates that `value` must be placed _before_ each of the attribute names in
the given list. For example

```nix
foo.bar = {
  b = lib.dag.entryBefore [ "a" ] 1;
  a = 0;
}
```

would place `b` before `a` in the graph.

## entryBetween {#sec-types-dag-entryBetween}

> `lib.dag.entryBetween (befores: list string) (afters: list string) (value: T) : DagEntry<T>`

Indicates that `value` must be placed _before_ the attribute names in the first
list and _after_ the attribute names in the second list. For example

```nix
foo.bar = {
  a = 0;
  c = lib.dag.entryBetween [ "b" ] [ "a" ] 2;
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

> `lib.dag.entriesAnywhere (tag: string) (values: [T]) : Dag<T>`

Creates a DAG with the given values with each entry labeled using the given tag.
For example

```nix
foo.bar = lib.dag.entriesAnywhere "a" [ 0 1 ];
```

is equivalent to

```nix
foo.bar = {
  a-0 = 0;
  a-1 = lib.dag.entryAfter [ "a-0" ] 1;
}
```

## entriesAfter {#sec-types-dag-entriesAfter}

> `lib.dag.entriesAfter (tag: string) (afters: list string) (values: [T]) : Dag<T>`

Creates a DAG with the given values with each entry labeled using the given tag.
The list of values are placed are placed _after_ each of the attribute names in
`afters`. For example

```nix
foo.bar =
  { b = 0; } // lib.dag.entriesAfter "a" [ "b" ] [ 1 2 ];
```

is equivalent to

```nix
foo.bar = {
  b = 0;
  a-0 = lib.dag.entryAfter [ "b" ] 1;
  a-1 = lib.dag.entryAfter [ "a-0" ] 2;
}
```

## entriesBefore {#sec-types-dag-entriesBefore}

> `lib.dag.entriesBefore (tag: string) (befores: list string) (values: [T]) : Dag<T>`

Creates a DAG with the given values with each entry labeled using the given tag.
The list of values are placed _before_ each of the attribute names in `befores`.
For example

```nix
foo.bar =
  { b = 0; } // lib.dag.entriesBefore "a" [ "b" ] [ 1 2 ];
```

is equivalent to

```nix
foo.bar = {
  b = 0;
  a-0 = 1;
  a-1 = lib.dag.entryBetween [ "b" ] [ "a-0" ] 2;
}
```

## entriesBetween {#sec-types-dag-entriesBetween}

> `lib.dag.entriesBetween (tag: string) (befores: list string) (afters: list string) (values: [T]) : Dag<T>`

Creates a DAG with the given values with each entry labeled using the given tag.
The list of values are placed _before_ each of the attribute names in `befores`
and _after_ each of the attribute names in `afters`. For example

```nix
foo.bar =
  { b = 0; c = 3; } // lib.dag.entriesBetween "a" [ "b" ] [ "c" ] [ 1 2 ];
```

is equivalent to

```nix
foo.bar = {
  b = 0;
  c = 3;
  a-0 = lib.dag.entryAfter [ "c" ] 1;
  a-1 = lib.dag.entryBetween [ "b" ] [ "a-0" ] 2;
}
```
