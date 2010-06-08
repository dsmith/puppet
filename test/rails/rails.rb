#!/usr/bin/env ruby1.8

require File.dirname(__FILE__) + '/../lib/puppettest'

require 'puppet'
require 'puppet/rails'
require 'puppet/parser/interpreter'
require 'puppet/parser/parser'
require 'puppet/network/client'
require 'puppettest'
require 'puppettest/parsertesting'
require 'puppettest/resourcetesting'
require 'puppettest/railstesting'

class TestRails < Test::Unit::TestCase
    include PuppetTest::ParserTesting
    include PuppetTest::ResourceTesting
    include PuppetTest::RailsTesting

    def test_includerails
        assert_nothing_raised {
            require 'puppet/rails'
        }
    end
end

