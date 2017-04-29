# balancer

Simple Tcp Balancer.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  balancer:
    github: kostya/balancer
```

## Usage

```crystal
require "balancer"

# run balancer listen on 0.0.0.0:3000
# and proxing all connections to 127.0.0.1:3001..3010
balancer = Balancer.new("0.0.0.0", 3000, "127.0.0.1", 3001..3010)
balancer.run
```
