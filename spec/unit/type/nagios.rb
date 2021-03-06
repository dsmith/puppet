#!/usr/bin/env ruby1.8

require File.dirname(__FILE__) + '/../../spec_helper'

require 'puppet/external/nagios'

describe "Nagios resource types" do
    Nagios::Base.eachtype do |name, nagios_type|
        puppet_type = Puppet::Type.type("nagios_" + name.to_s)

        it "should have a valid type for #{name}" do
            puppet_type.should_not be_nil
        end

        next unless puppet_type

        describe puppet_type do
            it "should be defined as a Puppet resource type" do
                puppet_type.should_not be_nil
            end

            it "should have documentation" do
                puppet_type.instance_variable_get("@doc").should_not == ""
            end

            it "should have %s as its namevar" % nagios_type.namevar do
                puppet_type.namevar.should == nagios_type.namevar
            end

            it "should have documentation for its %s parameter" % nagios_type.namevar do
                puppet_type.attrclass(nagios_type.namevar).instance_variable_get("@doc").should_not be_nil
            end

            it "should have an ensure property" do
                puppet_type.should be_validproperty(:ensure)
            end

            it "should have a target property" do
                puppet_type.should be_validproperty(:target)
            end

            it "should have documentation for its target property" do
                puppet_type.attrclass(:target).instance_variable_get("@doc").should_not be_nil
            end

            nagios_type.parameters.reject { |param| param == nagios_type.namevar or param.to_s =~ /^[0-9]/ }.each do |param|
                it "should have a %s property" % param do
                    puppet_type.should be_validproperty(param)
                end

                it "should have documentation for its %s property" % param do
                    puppet_type.attrclass(param).instance_variable_get("@doc").should_not be_nil
                end
            end

            nagios_type.parameters.find_all { |param| param.to_s =~ /^[0-9]/ }.each do |param|
                it "should have not have a %s property" % param do
                    puppet_type.should_not be_validproperty(:param)
                end
            end
        end
    end
end
