#!/usr/bin/env ruby1.8

require File.dirname(__FILE__) + '/../spec_helper'

require 'puppet/configurer'

describe Puppet::Configurer do
    describe "when downloading plugins" do
        it "should use the :pluginsignore setting, split on whitespace, for ignoring remote files" do
            resource = Puppet::Type.type(:notify).new :name => "yay"
            Puppet::Type.type(:file).expects(:new).with { |args| args[:ignore] == Puppet[:pluginsignore].split(/\s+/) }.returns resource

            configurer = Puppet::Configurer.new
            configurer.stubs(:download_plugins?).returns true
            configurer.download_plugins
        end
    end
end
