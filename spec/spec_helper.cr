require "spec"
require "../src/balancer"

def process(port, client)
  while s = client.gets
    s = s.chomp
    case s
    when "exit"
      break
    when "get_port"
      client.puts("#{port}")
    else
      client.puts(s)
    end
  end
rescue IO::EOFError
ensure
  client.close
end

def run_server(port)
  server = TCPServer.new "127.0.0.1", port
  spawn do
    loop { spawn process(port, server.accept) }
  end
end

PORTS = (13001..13010)

PORTS.each do |port|
  run_server(port)
end
