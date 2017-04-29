require "./spec_helper"

describe Balancer do
  it "works" do
    balancer = Balancer.new("127.0.0.1", 3000, "127.0.0.1", PORTS, Balancer::Method::Sample)
    balancer.background_run
    sleep 0.1

    res = [] of String
    100.times do |i|
      tcp = TCPSocket.new("127.0.0.1", 3000)
      tcp.puts("get_port")
      if msg = tcp.gets
        res << msg.chomp
      end
    end

    res.uniq.size.should eq PORTS.size
    res.uniq.sort.should eq PORTS.to_a.map(&.to_s)

    res.chunk(&.itself).size.should be > 30
    res.chunk(&.itself).size.should be <= 100
  end

  it "works" do
    balancer = Balancer.new("127.0.0.1", 3001, "127.0.0.1", PORTS, Balancer::Method::RoundRobin)
    balancer.background_run
    sleep 0.1

    res = [] of String
    100.times do |i|
      tcp = TCPSocket.new("127.0.0.1", 3001)
      tcp.puts("get_port")
      if msg = tcp.gets
        res << msg.chomp
      end
    end

    res.uniq.size.should eq PORTS.size
    res.uniq.sort.should eq PORTS.to_a.map(&.to_s)
    res.chunk(&.itself).size.should eq 100
  end
end
