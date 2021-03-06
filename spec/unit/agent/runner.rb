#!/usr/bin/env ruby1.8

require File.dirname(__FILE__) + '/../../spec_helper'
require 'puppet/agent'
require 'puppet/agent/runner'

describe Puppet::Agent::Runner do
    before do
        @runner = Puppet::Agent::Runner.new
    end

    it "should indirect :runner" do
        Puppet::Agent::Runner.indirection.name.should == :runner
    end

    it "should use a configurer agent as its agent" do
        agent = mock 'agent'
        Puppet::Agent.expects(:new).with(Puppet::Configurer).returns agent

        @runner.agent.should equal(agent)
    end

    it "should accept options at initialization" do
        lambda { Puppet::Agent::Runner.new :background => true }.should_not raise_error
    end

    it "should default to running in the foreground" do
        Puppet::Agent::Runner.new.should_not be_background
    end

    it "should default to its options being an empty hash" do
        Puppet::Agent::Runner.new.options.should == {}
    end

    it "should accept :tags for the agent" do
        Puppet::Agent::Runner.new(:tags => "foo").options[:tags].should == "foo"
    end

    it "should accept :ignoreschedules for the agent" do
        Puppet::Agent::Runner.new(:ignoreschedules => true).options[:ignoreschedules].should be_true
    end

    it "should accept an option to configure it to run in the background" do
        Puppet::Agent::Runner.new(:background => true).should be_background
    end

    it "should retain the background option" do
        Puppet::Agent::Runner.new(:background => true).options[:background].should be_nil
    end

    it "should not accept arbitrary options" do
        lambda { Puppet::Agent::Runner.new(:foo => true) }.should raise_error(ArgumentError)
    end

    describe "when asked to run" do
        before do
            @agent = stub 'agent', :run => nil, :running? => false
            @runner.stubs(:agent).returns @agent
        end

        it "should run its agent" do
            agent = stub 'agent2', :running? => false
            @runner.stubs(:agent).returns agent

            agent.expects(:run)

            @runner.run
        end

        it "should pass any of its options on to the agent" do
            @runner.stubs(:options).returns(:foo => :bar)
            @agent.expects(:run).with(:foo => :bar)

            @runner.run
        end

        it "should log its run using the provided options" do
            @runner.expects(:log_run)

            @runner.run
        end

        it "should set its status to 'already_running' if the agent is already running" do
            @agent.expects(:running?).returns true

            @runner.run

            @runner.status.should == "running"
        end

        it "should set its status to 'success' if the agent is run" do
            @agent.expects(:running?).returns false

            @runner.run

            @runner.status.should == "success"
        end

        it "should run the agent in a thread if asked to run it in the background" do
            Thread.expects(:new)

            @runner.expects(:background?).returns true

            @agent.expects(:run).never # because our thread didn't yield

            @runner.run
        end

        it "should run the agent directly if asked to run it in the foreground" do
            Thread.expects(:new).never

            @runner.expects(:background?).returns false
            @agent.expects(:run)

            @runner.run
        end
    end
end
