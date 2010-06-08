#!/usr/bin/env ruby1.8
#
#  Created by Luke A. Kanies on 2006-11-29.
#  Copyright (c) 2006. All rights reserved.

module PuppetTest::Support::Resources
    def tree_resource(name)
        Puppet::Type.type(:file).new :title => name, :path => "/tmp/#{name}", :mode => 0755
    end

    def tree_container(name)
        Puppet::Type::Component.create :name => name, :type => "yay"
    end

    def treenode(config, name, *resources)
        comp = tree_container name
        resources.each do |resource|
            if resource.is_a?(String)
                resource = tree_resource(resource)
            end
            config.add_edge(comp, resource)
            config.add_resource resource unless config.resource(resource.ref)
        end
        return comp
    end

    def mktree
        catalog = Puppet::Resource::Catalog.new do |config|
            one = treenode(config, "one", "a", "b")
            two = treenode(config, "two", "c", "d")
            middle = treenode(config, "middle", "e", "f", two)
            top = treenode(config, "top", "g", "h", middle, one)
        end

        return catalog
    end
end
