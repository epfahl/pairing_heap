defmodule PairingHeap do
  @readme "README.md"
  @external_resource @readme
  @moduledoc_readme @readme |> File.read!()

  @moduledoc """
  #{@moduledoc_readme}
  """

  defstruct root: :empty, size: 0, mode: nil, ordered?: nil

  alias PairingHeap.Node

  @type key :: any
  @type item :: any
  @type pair :: {key, item}
  @type mode :: :min | :max | {:min, module} | {:max, module}

  @type t :: %PairingHeap{
          root: :empty | Node.t(),
          size: non_neg_integer(),
          mode: mode(),
          ordered?: Node.ordered_fn()
        }

  @doc """
  Return an empty heap with the given `mode`.

  The `mode` can be one of

    * `:min` - a _min-heap_, where keys are compared with `&<=/2`
    * `:max` - a _max-heap_, where keys are compared with `&>=/2`
    * `{:min | :max, module}` - a min or max heap, where the `module` must
      implement a `compare` funciton with signature `(any, any -> :lt | :eq | :gt)`

  ## Examples

      iex> PairingHeap.new(:min)
      #PairingHeap<root: :empty, size: 0, mode: :min>
  """
  @spec new(mode) :: t
  def new(mode) do
    %PairingHeap{
      root: :empty,
      size: 0,
      mode: mode,
      ordered?: to_ordered_fn(mode)
    }
  end

  @doc """
  Return a heap with the given `mode` and insert each key-item pair in the
  given `list`.

  The `mode` can be one

    * `:min` - a _min-heap_, where keys are compared with `&<=/2`
    * `:max` - a _max-heap_, where keys are compared with `&>=/2`
    * `{:min | :max, module}` - a min or max heap, where the `module` must
      implement a `compare` funciton with signature `(any, any -> :lt | :eq | :gt)`

  ## Examples

      iex> PairingHeap.new(:min, [{2, :b}, {1, :a}])
      #PairingHeap<root: {1, :a}, size: 2, mode: :min>
  """
  @spec new(mode, [pair]) :: t
  def new(mode, []), do: new(mode)

  def new(mode, [{_, _} | _] = list) do
    Enum.reduce(list, new(mode), fn {key, item}, heap ->
      put(heap, key, item)
    end)
  end

  # Generates the `ordered?` function. If `ordered?.(key1, key2)` is true,
  # then the heap property is satisfied if a node with key `key1` is a parent of
  # a ndoe with key `key2`.
  @spec to_ordered_fn(mode) :: Node.ordered_fn()
  defp to_ordered_fn(:min), do: to_node_fn(&<=/2)
  defp to_ordered_fn(:max), do: to_node_fn(&>=/2)

  defp to_ordered_fn({:min, module}) when is_atom(module),
    do: to_node_fn(&(module.compare(&1, &2) != :gt))

  defp to_ordered_fn({:min, module}) when is_atom(module),
    do: to_node_fn(&(module.compare(&1, &2) != :lt))

  # Lift a function of two key to a function of two Nodes.
  @spec to_node_fn((key, key -> boolean)) :: Node.ordered_fn()
  defp to_node_fn(key_fn) do
    fn %Node{data: {key1, _}}, %Node{data: {key2, _}} ->
      key_fn.(key1, key2)
    end
  end

  @doc """
  Return `true` if the heap is empty, and `false` otherwise.

  ## Examples

      iex> PairingHeap.new(:min) |> PairingHeap.empty?()
      true
  """
  @spec empty?(t) :: boolean
  def empty?(%PairingHeap{root: :empty}), do: true
  def empty?(%PairingHeap{root: %PairingHeap.Node{}}), do: false

  @doc """
  Insert a new key and item to the heap and return the updated heap.

  ## Examples

      iex> PairingHeap.new(:min) |> PairingHeap.put(1, :a)
      #PairingHeap<root: {1, :a}, size: 1, mode: :min>
  """
  @spec put(t, key, item) :: t
  def put(%PairingHeap{root: :empty, size: 0} = heap, key, item) do
    %{heap | root: Node.new({key, item}, []), size: 1}
  end

  def put(
        %PairingHeap{root: %Node{} = node, size: size, ordered?: ordered?} = heap,
        key,
        item
      ) do
    %{
      heap
      | root: Node.merge(node, Node.new({key, item}, []), ordered?),
        size: size + 1
    }
  end

  @doc """
  Return the root key-item pair in the heap without modifying the heap.

  If the heap is non-empty, this returns `{:ok, {key, item}}`. If the heap is empty,
  `:error` is returned.

  ## Examples

      iex> PairingHeap.new(:min, [{1, :a}]) |> PairingHeap.peek()
      {:ok, {1, :a}}
  """
  @spec peek(t) :: {:ok, pair} | :error
  def peek(%PairingHeap{root: :empty}), do: :error
  def peek(%PairingHeap{root: %Node{data: {key, item}}}), do: {:ok, {key, item}}

  @doc """
  Return the root key-item pair in the heap, as well as the updated heap after
  the root is removed.

  If the heap is non-empty, this returns `{:ok, {key, item}, heap}`. If the heap
  is empty, `:error` is returned.

  ## Examples

      iex> {:ok, {key, item}, heap} =
      ...>   PairingHeap.new(:min, [{1, :a}])
      ...>   |> PairingHeap.pop()
      iex> {key, item}
      {1, :a}
      iex> heap
      #PairingHeap<root: :empty, size: 0, mode: :min>
  """
  @spec pop(t) :: {:ok, pair, t} | :error
  def pop(%PairingHeap{root: :empty}), do: :error

  def pop(
        %PairingHeap{
          root: %Node{data: {key, item}, children: children},
          size: size,
          ordered?: ordered?
        } = heap
      ) do
    heap =
      case children do
        [] -> %{heap | root: :empty, size: 0}
        [_ | _] -> %{heap | root: Node.merge(children, ordered?), size: size - 1}
      end

    {:ok, {key, item}, heap}
  end

  @doc """
  Return the size of the heap, the total number of nodes.

  ## Examples

      iex> PairingHeap.new(:min, [{1, :a}]) |> PairingHeap.size()
      1
  """
  @spec size(t) :: non_neg_integer()
  def size(%PairingHeap{size: size}), do: size

  @doc """
  Return the first `n` key-item pairs from the heap and the final state of the heap.

  If the heap `size` is less than `n`, all key-item pairs are returned, along with
  an empty heap.

  ## Examples

      iex> {items, heap} =
      ...>   PairingHeap.new(:min, [{3, :c}, {1, :a}, {2, :b}])
      ...>   |> PairingHeap.pull(2)
      iex> items
      [{1, :a}, {2, :b}]
      iex> heap
      #PairingHeap<root: {3, :c}, size: 1, mode: :min>
  """
  @spec pull(t, non_neg_integer) :: {[pair], t}
  def pull(heap, n) when is_integer(n) and n >= 0 do
    {data, heap} = pull(heap, n, [])
    {Enum.reverse(data), heap}
  end

  defp pull(heap, 0, acc), do: {acc, heap}

  defp pull(%PairingHeap{} = heap, n, acc) do
    case pop(heap) do
      {:ok, {key, item}, heap} ->
        pull(heap, n - 1, [{key, item} | acc])

      :error ->
        {acc, heap}
    end
  end

  @doc """
  Merge two heaps into a single heap.

  An exception will be raised if the modes of the two heaps are not identical.

  ## Examples

      iex> PairingHeap.merge(
      ...>   PairingHeap.new(:min, [{1, :a}]),
      ...>   PairingHeap.new(:min, [{2, :b}])
      ...> )
      #PairingHeap<root: {1, :a}, size: 2, mode: :min>
  """
  @spec merge(t, t) :: t
  def merge(%PairingHeap{mode: m1}, %PairingHeap{mode: m2}) when m1 != m2 do
    # TODO: Improve this error message
    raise ArgumentError, message: "when merging heaps, the modes must match"
  end

  def merge(%PairingHeap{root: :empty} = heap, %PairingHeap{root: :empty}), do: heap
  def merge(%PairingHeap{root: %Node{}} = heap, %PairingHeap{root: :emtpy}), do: heap
  def merge(%PairingHeap{root: :empty}, %PairingHeap{root: %Node{}} = heap), do: heap

  def merge(
        %PairingHeap{root: node1, size: size1, ordered?: ordered?} = heap,
        %PairingHeap{root: node2, size: size2}
      ) do
    %{heap | root: Node.merge([node1, node2], ordered?), size: size1 + size2}
  end

  @doc """
  Merge a list of one or more heaps into a single heap.

  An exception will be raised if the modes of the heaps are not identical.

  ## Examples

      iex> PairingHeap.merge([
      ...>   PairingHeap.new(:min, [{1, :a}]),
      ...>   PairingHeap.new(:min, [{2, :b}])
      ...> ])
      #PairingHeap<root: {1, :a}, size: 2, mode: :min>
  """
  @spec merge([t]) :: t
  def merge([heap]), do: heap
  def merge([heap1, heap2]), do: merge(heap1, heap2)
  def merge([heap1, heap2 | rest]), do: merge(merge(heap1, heap2), merge(rest))

  @doc """
  Retrun `true` if the `heap` contains the key-item `pair`, and `false`
  otherwise.

  ## Examples

      iex> heap = PairingHeap.new(:min, [{3, :c}, {1, :a}, {2, :b}])
      iex> heap |> PairingHeap.member?({2, :b})
      true
  """
  @spec member?(t, pair) :: boolean
  def member?(%PairingHeap{root: :empty}, _pair), do: false

  def member?(%PairingHeap{root: %Node{} = node, ordered?: ordered?}, {_, _} = pair) do
    Node.member?(node, pair, ordered?)
  end
end
