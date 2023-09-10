defimpl Inspect, for: PairingHeap do
  import Inspect.Algebra

  @spec inspect(PairingHeap.t(), Inspect.Opts.t()) :: Inspect.Algebra.t()
  def inspect(heap, opts) do
    opts = %Inspect.Opts{opts | charlists: :as_lists}

    pairs =
      for attr <- [:root, :size, :mode] do
        {attr, Map.get(heap, attr)}
      end

    container_doc("#PairingHeap<", pairs, ">", opts, fn
      {:root, root}, opts ->
        concat("root: ", root |> extract_root() |> to_doc(opts))

      {:size, size}, opts ->
        concat("size: ", to_doc(size, opts))

      {:mode, mode}, opts ->
        concat("mode: ", to_doc(mode, opts))
    end)
  end

  defp extract_root(:empty), do: :empty
  defp extract_root(%PairingHeap.Node{data: {key, item}}), do: {key, item}
end
