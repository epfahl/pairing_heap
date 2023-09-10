defmodule PairingHeap.Node do
  @moduledoc """
  Defines the `PairingHeap.Node` struct and functions for creating and
  combining nodes.

  The functions `PairingHeap.Node.merge/3` and `ParingHeap.Node.merge/2`
  combine pairs and lists of nodes, respectively, in a way that preserves the
  heap property. Both of these functions take as an argument the predicate
  `ordered?/2`, where `ordered?.(node1, node2)` returns `true` if `node1`
  is correctly ordered relatively to `node2` according to the heap property.
  """

  alias __MODULE__, as: Node

  defstruct [:data, :children]

  @type data :: any
  @type ordered_fn :: (t, t -> boolean)

  @type t :: %Node{
          data: data,
          children: [t]
        }

  @doc """
  Create a new pairing-heap node with associated data and a list of zero or
  more child nodes.
  """
  @spec new(data, [t]) :: t
  def new(data, children), do: %Node{data: data, children: children}

  @doc """
  Link a pair of nodes into a single node that satisfies the heap property.

  One of the given nodes is a parent and the other is the child, as determined
  by `ordered?/2`. The child node is prepended to the list of child nodes for
  the parent. No other maintenance is required for the individual nodes in a
  pairing heap. It follows that `meld` runs in `O(1)` time.
  """
  @spec merge(t, t, ordered_fn()) :: t
  def merge(
        %Node{children: children1} = node1,
        %Node{children: children2} = node2,
        ordered?
      ) do
    if ordered?.(node1, node2) do
      %{node1 | children: [node2 | children1]}
    else
      %{node2 | children: [node1 | children2]}
    end
  end

  @doc """
  Merge a list of nodes into a single node that satisfies the heap property.

  The pairwise recursive merger follows the algorithm described in the
  [original paper](https://www.cs.cmu.edu/~sleator/papers/pairing-heaps.pdf),
  which has `O(log n)` amortized run time.
  """
  @spec merge([t], ordered_fn) :: t
  def merge([node], _ordered?), do: node
  def merge([node1, node2], ordered?), do: merge(node1, node2, ordered?)

  def merge([node1, node2 | rest], ordered?) do
    merge(
      merge(node1, node2, ordered?),
      merge(rest, ordered?),
      ordered?
    )
  end

  @doc """
  Return `true` if any node in the tree defined by `node` contains `data`, and
  `false` otherwise.

  This recuresively searches the children only if the data can be among the
  children according to the heap property.
  """
  @spec member?(Node.t(), any, Node.ordered_fn()) :: boolean
  def member?(node, data, ordered?) do
    do_member?(node, new(data, []), ordered?)
  end

  defp do_member?(node, node_target, ordered?) do
    cond do
      node.data == node_target.data ->
        true

      ordered?.(node, node_target) ->
        Enum.any?(node.children, fn n -> do_member?(n, node_target, ordered?) end)

      true ->
        false
    end
  end
end
