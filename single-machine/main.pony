use "collections"

actor ComputeSquaredSumInWindow
  let _l: U64
  let _u: U64
  let _k: U64
  let _perfect_square_actor: CheckIfPerfectSquare
  let _print_actor: PrintToScreen

  new create(print_screen_actor: PrintToScreen, l: U64, u: U64, k: U64) =>
    _perfect_square_actor = CheckIfPerfectSquare
    _print_actor = print_screen_actor
    _l = l
    _u = u
    _k = k

  be compute() =>
    // Sum of squares in the first k-size window 
    var sum: U64 = 0
    var window_start: U64 = _l
    var window_end: U64 = window_start + (_k - 1)

    for i in Range[U64](window_start, window_end+1) do
      sum = sum + (i * i)
    end

    while window_start <= _u do
      _perfect_square_actor.is_perfect_square(_print_actor, sum, window_start)
      sum = sum - (window_start * window_start)
      window_start = window_start + 1
      window_end = window_end + 1
      sum = sum + (window_end * window_end)
    end


actor CheckIfPerfectSquare
  fun sqrt(num: U64): U64 =>
    var low: U64 = 0
    var high: U64 = num
    while low <= high do
      let mid: U64 = (low + high) / 2
      let mid_sq: U64 = mid * mid
      if mid_sq == num then
        return mid
      elseif mid_sq < num then
        low = mid + 1
      else
        high = mid - 1
      end
    end
    high
  
  be is_perfect_square(print_screen_actor: PrintToScreen, num: U64, window_start: U64) =>
    let root: U64 = sqrt(num)
    if (root * root) == num then
      print_screen_actor.printOutputToScreen(num, window_start)
    end

actor PrintToScreen
    let _out: OutStream 
    
    new create(out: OutStream) =>
        _out = out

    be printOutputToScreen(num: U64, window_start: U64) =>
        _out.print(window_start.string())

actor Main
  new create(env: Env) =>
    let n: U64 = try env.args(2)?.u64()? else -1 end
    let k: U64 = try env.args(3)?.u64()? else -1 end
    let number_of_cores: U64 = try env.args(4)?.u64()? else 8 end
    let half_number_of_cores: U64 = number_of_cores/2
    let print_screen_actor = PrintToScreen(env.out)
    if (k != -1) and (n != -1) and (n >= k) then
      var chunk_size: U64 = if (n / half_number_of_cores) > 0 then (n / half_number_of_cores) else n end //each actor world work on chunk_size+k-1
      var chunk_start: U64 = 1
      var chunk_end: U64 = 0
      // Creating actor instances for each core and distribute the computation
      while (chunk_start <= n) do
        chunk_end = if (chunk_start + chunk_size) > n then n else (chunk_start + (chunk_size - 1)) end
        ComputeSquaredSumInWindow(print_screen_actor, chunk_start, chunk_end, k).compute()
        chunk_start = chunk_start + chunk_size
      end
    end
