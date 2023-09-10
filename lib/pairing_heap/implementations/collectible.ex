defimpl Collectable, for: PairingHeap do
  @spec into(PairingHeap.t()) ::
          {term(), (term(), Collectable.command() -> PairingHeap.t() | term())}
  def into(heap) do
    collector_fun = fn
      heap_acc, {:cont, {key, item}} -> PairingHeap.put(heap_acc, key, item)
      heap_acc, :done -> heap_acc
      _heap_acc, :halt -> :ok
    end

    {heap, collector_fun}
  end
end
