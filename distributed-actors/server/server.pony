use "net"
use "collections"

actor ComputeSquaredSumInWindow
  let _l: U64
  let _u: U64
  let _k: U64
  let _perfect_square_actor: CheckIfPerfectSquare
  let _print_actor: WriteResultToClient

  new create(write_result_to_client: WriteResultToClient, l: U64, u: U64, k: U64) =>
    _perfect_square_actor = CheckIfPerfectSquare
    _print_actor = write_result_to_client
    _l = l
    _u = u
    _k = k

  be compute() =>
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
  
  be is_perfect_square(write_result_to_client: WriteResultToClient, num: U64, window_start: U64) =>
    let root: U64 = sqrt(num)
    if (root * root) == num then
      write_result_to_client.write(window_start)
    else
      write_result_to_client.decrement_pending()
    end

actor WriteResultToClient
  let _conn: TCPConnection tag
  var _pending: U64
  var _buffer: Array[U64] ref = Array[U64]

  new create(conn: TCPConnection tag, pending_actors: U64) =>
    _conn = conn
    _pending = pending_actors

  be write(window_start: U64) =>
    _buffer.push(window_start)
    decrement_pending()

  be decrement_pending() =>
    _pending = _pending - 1
    if _pending == 0 then
      // All computations are done, now write the buffered result to the connection
      _conn.write(join(_buffer, " "))
    end

  fun join(arr: Array[U64], separator: String): String =>
    var result: String = " "
    var first: Bool = true

    for elem in arr.values() do
      if first then
        first = false
      else
        result = result + separator
      end
      result = result + elem.string()
    end
    result