require "socket"

class Balancer
  VERSION = "0.1"

  enum Method
    Sample
    RoundRobin
  end

  @target_ports : Array(Int32)

  def initialize(@listen_host : String,
                 @listen_port : Int32,
                 @target_host : String,
                 target_ports : Range(Int32, Int32) | Array(Int32),
                 @method = Method::Sample)
    @stopped = false
    @server = TCPServer.new @listen_host, @listen_port
    @connections_count = 0
    @target_ports = target_ports.to_a
    @port_id = 0
  end

  def run
    loop do
      break if @stopped
      conn = @server.accept
      spawn handle(conn)
    end
  end

  def background_run
    spawn { run }
  end

  def stop!
    @stopped = true
  end

  def connections_count
    @connections_count / 2
  end

  private def target_port
    case @method
    when Method::Sample
      @target_ports.sample
    when Method::RoundRobin
      port = @target_ports[@port_id]
      @port_id += 1
      @port_id = 0 if @port_id >= @target_ports.size
      port
    end
  end

  private def handle(client)
    @connections_count += 2
    sock = TCPSocket.new(@target_host, target_port)
    spawn copy_io(client, sock)
    spawn copy_io(sock, client)
  end

  private def copy_io(r, w)
    IO.copy(r, w)
  rescue IO::Error
  rescue Socket::Error
  rescue IO::TimeoutError
  ensure
    w.close
    r.close
    @connections_count -= 1
  end
end
