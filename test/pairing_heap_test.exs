defmodule PairingHeapTest do
  use ExUnit.Case, async: true
  doctest PairingHeap

  describe "nodes" do
    test "create" do
      assert true
    end
  end

  describe "basic operations" do
    test "new min-heap, put, and pop" do
      h =
        PairingHeap.new(:min)
        |> PairingHeap.put(2, :b)
        |> PairingHeap.put(1, :a)

      assert {:ok, {1, :a}, _} = PairingHeap.pop(h)
    end

    test "new max-heap, put, and pop" do
      h =
        PairingHeap.new(:max)
        |> PairingHeap.put(2, :b)
        |> PairingHeap.put(1, :a)

      assert {:ok, {2, :b}, _} = PairingHeap.pop(h)
    end

    test "sort on module compare" do
      h = PairingHeap.new({:min, Date}, [{~D[2023-12-02], :b}, {~D[2023-12-01], :a}])
      assert {:ok, {~D[2023-12-01], :a}, _} = PairingHeap.pop(h)
    end

    test "size after put and pop" do
      h =
        PairingHeap.new(:min, [{2, :b}, {2, :a}])

      {:ok, _, h} = PairingHeap.pop(h)

      assert PairingHeap.size(h) == 1
    end

    test "error after pop on empty heap" do
      h = PairingHeap.new(:min)

      assert PairingHeap.pop(h) == :error
    end

    test "peek" do
      h = PairingHeap.new(:min, [{2, :b}, {1, :a}, {3, :c}])

      assert {:ok, {1, :a}} = PairingHeap.peek(h)
    end

    test "pull pairs" do
      h = PairingHeap.new(:min, [{2, :b}, {1, :a}, {3, :c}])
      {pairs, _} = PairingHeap.pull(h, 2)
      assert pairs == [{1, :a}, {2, :b}]
    end

    test "merge two heaps" do
      h1 = PairingHeap.new(:min, [{2, :b}, {1, :a}])
      h2 = PairingHeap.new(:min, [{3, :c}, {4, :d}])
      h = PairingHeap.merge(h1, h2)

      assert {:ok, {1, :a}} = PairingHeap.peek(h)
    end

    test "merge a list of heaps" do
      h1 = PairingHeap.new(:min, [{2, :b}, {1, :a}])
      h2 = PairingHeap.new(:min, [{3, :c}, {4, :d}])
      h = PairingHeap.merge([h1, h2])

      assert {:ok, {1, :a}} = PairingHeap.peek(h)
    end

    test "membership" do
      h = PairingHeap.new(:min, [{2, :b}, {1, :a}])

      assert PairingHeap.member?(h, {2, :b})
      assert not PairingHeap.member?(h, {3, :c})
    end

    test "empty?" do
      h = PairingHeap.new(:max)
      assert PairingHeap.empty?(h)
    end
  end

  describe "enumerable implementation" do
    test "enumerable count" do
      h = PairingHeap.new(:min, [{2, :b}, {1, :a}])
      assert Enum.count(h) == 2
    end

    test "enumerable member?" do
      h = PairingHeap.new(:min, [{2, :b}, {1, :a}])
      assert Enum.member?(h, {2, :b})
    end

    test "enumerable reduce" do
      h = PairingHeap.new(:min, [{2, 100}, {1, 200}])
      value_sum = Enum.reduce(h, 0, fn {_, v}, acc -> acc + v end)
      assert value_sum == 300
    end
  end

  describe "collectable implementation" do
    test "into a list" do
      h = PairingHeap.new(:min, [{2, :b}, {1, :a}])
      assert Enum.into(h, []) == [{1, :a}, {2, :b}]
    end

    test "into a map" do
      h = PairingHeap.new(:min, [{2, :b}, {1, :a}])
      assert Enum.into(h, %{}) == %{1 => :a, 2 => :b}
    end
  end

  describe "duplicate root key" do
    test "item with key equal to root key replace root in min-heap" do
      h =
        PairingHeap.new(:min, [{2, :b}, {1, :a}, {3, :c}])
        |> PairingHeap.put(1, :aa)
        |> PairingHeap.put(1, :aaa)

      {first_three, _} = PairingHeap.pull(h, 3)

      assert first_three == [{1, :aaa}, {1, :aa}, {1, :a}]
    end

    test "item with key equal to root key replace root in max-heap" do
      h =
        PairingHeap.new(:max, [{2, :b}, {1, :a}, {3, :c}])
        |> PairingHeap.put(3, :cc)
        |> PairingHeap.put(3, :ccc)

      {first_three, _} = PairingHeap.pull(h, 3)

      assert first_three == [{3, :ccc}, {3, :cc}, {3, :c}]
    end
  end
end
