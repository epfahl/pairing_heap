defimpl Enumerable, for: PairingHeap do
  @spec count(PairingHeap.t()) :: {:ok, non_neg_integer()} | {:error, module}
  def count(heap), do: {:ok, PairingHeap.size(heap)}

  @spec member?(PairingHeap.t(), {PairingHeap.key(), PairingHeap.item()}) ::
          {:ok, boolean} | {:error, module}
  def member?(heap, {key, item}) do
    {:ok, PairingHeap.member?(heap, {key, item})}
  end

  @spec reduce(PairingHeap.t(), Enumerable.acc(), Enumerable.reducer()) :: Enumerable.result()
  def reduce(_heap, {:halt, acc}, _fun), do: {:halted, acc}
  def reduce(heap, {:suspend, acc}, fun), do: {:suspended, acc, &reduce(heap, &1, fun)}

  def reduce(heap, {:cont, acc}, fun) do
    case PairingHeap.pop(heap) do
      :error ->
        {:done, acc}

      {:ok, {key, item}, heap} ->
        reduce(heap, fun.({key, item}, acc), fun)
    end
  end

  def slice(_heap), do: {:error, __MODULE__}
end
