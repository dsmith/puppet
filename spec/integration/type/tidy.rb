#!/usr/bin/env ruby1.8

require File.dirname(__FILE__) + '/../../spec_helper'

require 'puppet_spec/files'

describe Puppet::Type.type(:tidy) do
    include PuppetSpec::Files

    # Testing #355.
    it "should be able to remove dead links" do
        dir = tmpfile("tidy_link_testing")
        link = File.join(dir, "link")
        target = tmpfile("no_such_file_tidy_link_testing")
        Dir.mkdir(dir)
        File.symlink(target, link)

        tidy = Puppet::Type.type(:tidy).new :path => dir, :recurse => true

        catalog = Puppet::Resource::Catalog.new
        catalog.add_resource(tidy)

        catalog.apply

        FileTest.should_not be_symlink(link)
    end
end
