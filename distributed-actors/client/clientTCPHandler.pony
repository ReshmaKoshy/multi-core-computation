use "net"

class ClientTCPConnectionNotify is TCPConnectionNotify
  let _out: OutStream
  let _low: U64
  let _high: U64
  let _k: U64
  let _print_screen_actor: PrintToScreen

  new create(out: OutStream, low: U64, high: U64, k: U64, print_screen_actor: PrintToScreen) =>
    _out = out
    _low = low
    _high = high
    _k = k 
    _print_screen_actor = print_screen_actor

  fun ref connected(conn: TCPConnection ref) =>
    conn.write(_low.string() + " " + _high.string()+ " " + _k.string())

  fun ref received(
    conn: TCPConnection ref,
    data: Array[U8] iso,
    times: USize)
    : Bool
  =>
    var first: Bool = true
    let result_from_server: Array[String] = String.from_array(consume data).split(" ")
    for elem in result_from_server.values() do
        if first then
            first = false
        else
            _out.print("FROM REMOTE:" + elem.string())
            //var r = try elem.u64()? else conn.write("Non-U64 result from server" + "\n"); conn.close(); return false end
            //_print_screen_actor.printOutputToScreen(r)   
        end
    end
    conn.close()
    true

  fun ref connect_failed(conn: TCPConnection ref) =>
    _out.print("Connection to server failed.")