defmodule Utilities.TestFunctions do
  @data %{
    schwefel: {
      fn _ -> 0 end,
      fn vector ->
        length = Arrays.size(vector)
        k = 418.9829

        sum =
          Arrays.reduce(vector, 0, fn x, res ->
            res + -1.0 * x * Math.sin(Math.sqrt(abs(x)))
          end)

        sum + k * length
      end
    },
    rastrigin: {
      fn _ -> 0 end,
      fn vector ->
        Arrays.reduce(vector, 0, fn x, sum ->
          sum + (x ** 2 - 10 * Math.cos(2 * Math.pi() * x) + 10)
        end)
      end
    },
    ackley: {
      fn _ -> 0 end,
      fn vector ->
        length = Arrays.size(vector)

        {squares_sum, cos_sum} =
          Arrays.reduce(vector, {0, 0}, fn x, {squares_sum, cos_sum} ->
            {
              squares_sum + x ** 2,
              cos_sum + Math.cos(2 * Math.pi() * x)
            }
          end)

        avg_squares = squares_sum / length
        avg_cos = cos_sum / length
        first = -20 * Math.exp(-0.2 * Math.sqrt(avg_squares))
        second = -1 * Math.exp(avg_cos)
        third = 20 + Math.exp(1)
        first + second + third
      end
    },
    griewank: {
      fn _ -> 0 end,
      fn vector ->
        length = Arrays.size(vector)

        {sum, prod} =
          0..(length - 1)
          |> Enum.reduce({0, 0}, fn i, {sum, prod} ->
            x = vector[i]

            {
              sum + x ** 2,
              prod * Math.cos(x / Math.sqrt(i + 1))
            }
          end)

        1.0 / 4000 * sum - prod + 1
      end
    },
    "levy 1": {
      fn _ -> 0 end,
      fn vector ->
        length = Arrays.size(vector)
        y = fn x -> 1 + (x + 1) / 4 end

        u = fn x, a, k, m ->
          cond do
            x > a ->
              k * (x - a) ** m

            x in (-1 * a)..a ->
              0

            x < -1 * a ->
              k * (-1 * (x + a)) ** m
          end
        end

        left = 10 * Math.sin(Math.pi() * y.(vector[0])) ** 2

        middle =
          1..(length - 2)
          |> Enum.reduce(0, fn i, sum ->
            sum + (y.(vector[i]) - 1) * (1 + 10 * Math.sin(Math.pi() * y.(i + 1)) ** 2)
          end)

        right = (y.(vector[length - 1]) - 1) ** 2

        u_sum =
          Arrays.reduce(vector, 0, fn x, sum ->
            sum + u.(x, 10, 100, 4)
          end)

        Math.pi() / length * (left + middle + right) + u_sum
      end
    },
    "levy 2": {
      fn _ -> 0 end,
      fn vector ->
        length = Arrays.size(vector)

        u = fn x, a, k, m ->
          cond do
            x > a ->
              k * (x - a) ** m

            x in (-1 * a)..a ->
              0

            x < -1 * a ->
              k * (-1 * (x + a)) ** m
          end
        end

        left = Math.sin(3 * Math.pi() * vector[0]) ** 2

        middle =
          1..(length - 2)
          |> Enum.reduce(0, fn i, sum ->
            sum + (vector[i] - 1) ** 2 * (1 + Math.sin(3 * Math.pi() * vector[i + 1]) ** 2)
          end)

        right =
          (vector[length - 1] - 1) ** 2 *
            (1 + Math.sin(2 * Math.pi() * vector[length - 1]) ** 2)

        u_sum =
          Arrays.reduce(vector, 0, fn x, sum ->
            sum + u.(x, 5, 100, 4)
          end)

        (left + middle + right) / 10 + u_sum
      end
    },
    michalewicz: {
      # revise the local minima
      fn dimension ->
        cond do
          dimension == 30 -> -28.9263
          dimension == 100 -> -99.2784
          true -> raise("this dimension has no optimal value")
        end
      end,
      fn vector ->
        length = Arrays.size(vector)

        sum =
          0..(length - 1)
          |> Enum.reduce(0, fn i, sum ->
            x = vector[i]
            sum + Math.sin(x) * Math.sin(i / Math.pi() * x ** 2) ** 20
          end)

        sum * -1.0
      end
    },
    #   brown: {
    #     fn _ -> 0 end,
    #     fn vector ->
    #       length = Arrays.size(vector)

    #       0..length(-2)
    #       |> Enum.reduce(0, fn i, sum ->
    #         sum + vector[i] ** 2 ** (vector[i + 1] ** 2 + 1) +
    #           vector[i + 1] ** 2 ** (vector[i] ** 2 + 1)
    #       end)
    #     end
    #   }
    # },
    "styblinki-tang": {
      fn _ -> -78.33236 end,
      fn vector ->
        length = Arrays.size(vector)

        sum =
          Arrays.reduce(vector, 0, fn x, sum ->
            sum + x ** 4 - 16 * x ** 2 + 5 * x
          end)

        sum / length
      end
    },
    rosenbrock: {
      fn _ -> 0 end,
      fn vector ->
        length = Arrays.size(vector)

        0..(length - 2)
        |> Enum.reduce(0, fn i, sum ->
          sum + 100 * (vector[i] ** 2 - vector[i + 1]) ** 2 + (vector[i] - 1) ** 2
        end)
      end
    },
    sphere: {
      fn _ -> 0 end,
      fn vector ->
        Arrays.reduce(vector, 0, fn x, sum -> sum + x ** 2 end)
      end
    },
    noisy_quartic: {
      fn _ -> 0 end,
      fn vector ->
        Arrays.reduce(vector, 0, fn x, sum -> sum + x ** 4 + :rand.uniform_real() end)
      end
    },
    "schwefel2.22": {
      fn _ -> 0 end,
      fn vector ->
        Arrays.reduce(vector, {0, 0}, fn x, {sum, prod} ->
          {
            sum + abs(x),
            prod * abs(x)
          }
        end)
      end
    },
    "schwefel1.2": {
      fn _ -> 0 end,
      fn vector ->
        length = Arrays.size(vector)

        0..(length - 1)
        |> Enum.reduce(0, fn i, sum1 ->
          sum2 =
            0..i
            |> Enum.reduce(0, fn j, res -> res + vector[j] end)

          sum1 + sum2 ** 2
        end)
      end
    },
    "schwefel2.21": {
      fn _ -> 0 end,
      fn vector ->
        Enum.max_by(vector, &abs(&1))
      end
    }
  }
end
