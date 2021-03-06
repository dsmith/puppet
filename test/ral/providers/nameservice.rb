#!/usr/bin/env ruby1.8

require File.dirname(__FILE__) + '/../../lib/puppettest'

require 'puppettest'
require 'puppet/provider/nameservice'
require 'facter'

class TestNameServiceProvider < Test::Unit::TestCase
    include PuppetTest::FileTesting

    def test_option
        klass = Class.new(Puppet::Provider::NameService)
        klass.resource_type = Puppet::Type.type(:user)

        val = nil
        assert_nothing_raised {
            val = klass.option(:home, :flag)
        }

        assert_nil(val, "Got an option")

        assert_nothing_raised {
            klass.options :home, :flag => "-d"
        }
        assert_nothing_raised {
            val = klass.option(:home, :flag)
        }
        assert_equal("-d", val, "Got incorrect option")
    end
end

