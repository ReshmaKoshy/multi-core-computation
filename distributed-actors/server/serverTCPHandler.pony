use "net"
use "collections"

class ServerTCPConnectionNotify is TCPConnectionNotify
  
  let _number_of_cores: U64

  new create(number_of_cores: U64) =>
    _number_of_cores = number_of_cores

  fun ref received(
    conn: TCPConnection ref,
    data: Array[U8] iso,
    times: USize)
    : Bool
  =>
    let received_str = String.from_array(consume data)
    try
      let parts = received_str.split(" ")
      if parts.size() == 3 then
        let l = parts(0)?.u64()?
        let u = parts(1)?.u64()? 
        let k = parts(2)?.u64()? 
        
        let half_number_of_cores: U64 = _number_of_cores/2
        var chunk_size: U64 = if ( ((u - l) + 1) / half_number_of_cores) > 0 then ( ((u - l) + 1) / half_number_of_cores) else ((u - l) + 1) end //each actor world work on chunk_size+k-1
        var chunk_start: U64 = l
        var chunk_end: U64 = 0
        let chunk_count = (u - l) + 1
        let write_result_to_client = WriteResultToClient(conn, chunk_count)
        // Creating actor instances for each core and distribute the computation
        while (chunk_start <= u) do
            chunk_end = if (chunk_start + chunk_size) > u then u else (chunk_start + (chunk_size - 1)) end
            ComputeSquaredSumInWindow(write_result_to_client, chunk_start, chunk_end, k).compute()
            chunk_start = chunk_start + chunk_size
        end
      else
        conn.write("Invalid input: " + received_str + "\n")
      end
    else
      conn.write("Invalid input: " + received_str + "\n")
    end
    true

  fun ref connect_failed(conn: TCPConnection ref) =>
    None

class ServerTCPListenNotify is TCPListenNotify

  let _number_of_cores: U64

  new create(number_of_cores: U64) =>
    _number_of_cores = number_of_cores

  fun ref connected(listen: TCPListener ref): TCPConnectionNotify iso^ =>
    recover ServerTCPConnectionNotify(_number_of_cores) end

  fun ref not_listening(listen: TCPListener ref) =>
    None

actor Main
  new create(env: Env) =>
    let host: String = try env.args(1)? else "127.0.0.1" end
    let port: String = try env.args(2)? else "8989" end
    let number_of_cores: U64 = try env.args(3)?.u64()? else 8 end
    TCPListener(TCPListenAuth(env.root),
      ServerTCPListenNotify(number_of_cores), host, port)
