# pcp_easy
`pcp_easy` provides a simple Ruby API to query metrics from a remote [Performance Co-Pilot] \(PCP\) daemon.
## Install
`pcp_easy` version 0.4.0+ uses the Ruby `ffi` gem to call into native `libpcp`. Compilation and development headers are not required.
```sh
gem install pcp_easy
```

## Usage
The API is still in flux and is subject to change until a stable (1.0.0) version is released.
```ruby
require 'pcp_easy'

# Connect to a remote agent
agent = PCPEasy::Agent.new('localhost')

# Metrics that have no instances return a single element array of values
metric = agent.metric('disk.all.read')
puts metric.inspect
#<PCPEasy::Metric
#  @name="disk.all.read",
#  @values=[<PCPEasy::Metric::Value:0x007f05b2b21970 @value=116044, @instance=nil>],
#  @semantics=:counter,
#  @type=:uint64
#  @units={:domain=>:count0, :range=>nil}>

# Metrics that have instances return an array of values
metrics = agent.metric('disk.partitions.read')
puts metrics.inspect
#<PCPEasy::Metric
#  name="disk.partitions.read",
#  values=[
#    <PCPEasy::Metric::Value:0x007f05b2b21920 @value=177, @instance="sda1">,
#    <PCPEasy::Metric::Value:0x007f05b2b218d0 @value=115805, @instance="sda5>,
#  ],
#  semantics=:counter,
#  type=:uint64,
#  units={:domain=>:count0, :range=>nil}>,
```

All `pcp_easy` exceptions extend from `PCPEasy::Error`. There is a one-to-one mapping of PCP errors
to error classes (see: `lib/pcp_easy/error.rb`).

```ruby
require 'pcp_easy'

agent = PCPEasy::Agent.new('localhost')
begin
  agent.metric('not.a.metric')
  # raises PCPEasy::NameError
rescue PCPEasy::NameError
  puts 'could not query for metric with unknown name'
end

```

## Extending and hacking
`pcp_easy` tries to hide the internals of PCP by returning most of the information about a metric via the
`PCPEasy::Metric` object. The C API represents this over several structs and API calls which is done
when `PCPEasy::Agent#metric` is called.

A more C-like API is currently being developed [here](https://github.com/ryandoyle/pcp/tree/ruby-bindings).
It's unlikely that anything more than simple metric lookups will be implemented in `pcp_easy` and
I don't really intend to make it too more feature-ful than the minimal API already is.

Having said that, if there is a feature that you feel is a good place for `pcp_easy`, create an issue
so we can decide if it fits in this API. If you want to develop locally, you will need `pcp` installed
and running with the `sample` PMDA installed.

The following is an example for a Debian-based system.

```sh
# Install pcp & ruby
apt-get install pcp ruby

# Install the sample PMDA
cd /var/lib/pcp/pmdas/sample/
echo | sudo ./Install
cd

# Checkout the code and install dependencies
git clone https://github.com/ryandoyle/pcp_easy.git
cd pcp_easy
gem install bundler
bundle install

# Run the tests
bundle exec rake spec
```

   [performance co-pilot]: <http://pcp.io/>
