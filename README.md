Elixir implementation of a
[_pairing heap_](https://en.wikipedia.org/wiki/Pairing_heap).

## Background

A heap is a tree data structure that ensures that the root always has the 
minimum or maximum key value, depending on the desired sort order. The heap was 
first introduced in the context of efficient sorting 
(see [_heapsort_](https://en.wikipedia.org/wiki/Heapsort)), but it can also be 
used to implement a 
[priority queue](https://en.wikipedia.org/wiki/Priority_queue).  

Each node of a heap has a _key_ on which the data is ordered, as well as a
collection of child nodes. Every heap node satisfies the _heap property_
that the node key is either less than or equal to 
(a _min-heap_) or greater than or equal to (a _max-heap_) the keys of its
children. In a min-heap, the root node has the smallest key in the tree, while 
for a max-heap, the root key is the largest.

A pairing heap is one of a handful of commonly-used heap data structures. It
has excellent performance characteristics, with `O(1)` time complexity for an
insert and for viewing the root node, and `O(log n)` amortized time complexity 
for removing the root node and rebuilding the heap. The algorithms for 
maintaining a pairing heap have especially simple implementations in a
functional language, which is one reason for doing this in Elixir. 

## Usage

`PairingHeap` provides operations for the creation of a heap, for insertion, 
retrieval, and deletion of elements, and for merging multiple heaps.

To create an empty min-heap that compares keys with `&<=/2`, use 
`PairingHeap.new/1`:

```elixir
iex> PairingHeap.new(:min)
#PairingHeap<root: :empty, size: 0, mode: :min>
```

An empty heap is indicated with `root: :empty`.

> The `PairingHeap` struct is not intended to be used directly. Use the 
> public API when working with an instance of `PairingHeap`.

The data contained in each node of a heap is a key-item pair expressed as the 
tuple `{key, item}`. A `key` is what is being ordered in the heap, while the 
`item` can be data of any type. Note that a heap is a not a set; duplicate 
keys, items, and key-items pairs can be present.

Multiple key-item pairs can be added to a heap at the time of creation with 
`PairingHeap.new/2`:

```elixir
iex> PairingHeap.new(:min, [{2, :b}, {1, :a}])
#PairingHeap<root: {1, :a}, size: 2, mode: :min>
```

The first argument to `PairingHeap.new/1` and `PairingHeap.new/2` is the `mode`
of the heap, which can be one of

  * `:min` - a min-heap, where keys are compared with `&<=/2`
  * `:max` - a max-heap, where keys are compared with `&>=/2`
  * `{:min | :max, module}` - a min- or max-heap, where the `module` must
      implement a `compare` function with signature `(any, any -> :lt | :eq | :gt)`

For example, a min-heap with `Date` keys would be initialized as

```elixir
iex> PairingHeap.new({:min, Date}, [{~D[2023-09-01], :b}, {~D[2023-08-01], :a}])
#PairingHeap<root: {~D[2023-08-01], :a}, size: 2, mode: {:min, Date}>
```

To add a single key-item pair to a heap, use `PairingHeap.put/3`:

```eliixr
iex> PairingHeap.new(:min) |> PairingHeap.put(1, :a)
#PairingHeap<root: {1, :a}, size: 1, mode: :min>
```

`PairingHeap.peek/1` is used to obtained the key-item pair of the root without
modifying the heap:

```elixir
iex> PairingHeap.new(:min, [{1, :a}]) |> PairingHeap.peek()
{:ok, {1, :a}}
```

Extraction and removal of the root node is accomplished with `PairingHeap.pop/1`:

```elixir
iex> {:ok, {key, item}, heap} = 
...>   PairingHeap.new(:min, [{1, :a}]) 
...>   |> PairingHeap.pop()
iex> {key, item}
{1, :a}
iex> heap
#PairingHeap<root: :empty, size: 0, mode: :min>
```

Both `PairingHeap.peek/1` and `PairingHeap.pop/1` return `:error` if the
heap is empty.

`PairingHeap.pull/2` pops zero or more items from the heap and returns the 
updated heap:

```elixir
iex> {items, heap} =
...>   PairingHeap.new(:min, [{3, :c}, {1, :a}, {2, :b}])
...>   |> PairingHeap.pull(2)
iex> items
[{1, :a}, {2, :b}]
iex> heap
#PairingHeap<root: {3, :c}, size: 1, mode: :min>
```

If the number in `PairingHeap.pull/2` is greater than the heap size, all of the 
key-item pairs are returned, along with an empty heap.

Two heaps with the same `mode` can be merged with `PairingHeap.merge/2`:

```elixir
iex> heap1 = PairingHeap.new(:min, [{2, :b}])
iex> heap2 = PairingHeap.new(:min, [{1, :a}])
iex> PairingHeap.merge(heap1, heap2)
#PairingHeap<root: {1, :a}, size: 2, mode: :min>
```

Similarly, one or more heaps can be merged with `PairingHeap.merge/1`, which 
takes a list of heaps as its sole argument:

```elixir
iex> heap1 = PairingHeap.new(:min, [{2, :b}])
iex> heap2 = PairingHeap.new(:min, [{1, :a}])
iex> PairingHeap.merge([heap1, heap2])
#PairingHeap<root: {1, :a}, size: 2, mode: :min>
```

## Enumerable and Collectable

`PairingHeap` implements the `Enumerable` and `Collectable` protocols, meaning
that functions from `Enum` and `Stream` are available. 

`Enum.into` is a simple way to add a batch of key-item pairs to a heap:

```elixir
iex> heap = PairingHeap.new(:min, [{2, :b}])
iex> [{3, :c}, {1, :a}] |> Enum.into(heap)
#PairingHeap<root: {1, :a}, size: 3, mode: :min>
```

Use `Enum.to_list` to list the entire contents of the heap in key order:

```elixir
iex> heap = PairingHeap.new(:min, [{3, :c}, {1, :a}, {2, :b}])
iex> heap |> Enum.to_list()
[{1, :a}, {2, :b}, {3, :c}]
```

`map`, `filter`, and `reduce` are also available for `PairingHeap`. But beware:  

> Any operation that pops `k` elements from a heap will have `O(k log n)`
> complexity on average.
