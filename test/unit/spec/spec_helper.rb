require 'chefspec'
require 'chefspec/berkshelf'
require 'rspec/expectations'

::PLATFORM_OPTS = {
  platform: 'ubuntu',
  version: '14.04'
  # log_level: error (default: warn)
}

def stub_commands
  stub_command('which sudo').and_return('/usr/bin/sudo')
end

at_exit { ChefSpec::Coverage.report! }
