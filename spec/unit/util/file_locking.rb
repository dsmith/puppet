#!/usr/bin/env ruby1.8

Dir.chdir(File.dirname(__FILE__)) { (s = lambda { |f| File.exist?(f) ? require(f) : Dir.chdir("..") { s.call(f) } }).call("spec/spec_helper.rb") }

require 'puppet/util/file_locking'

class FileLocker
    include Puppet::Util::FileLocking
end

describe Puppet::Util::FileLocking do
    it "should have a module method for getting a read lock on files" do
        Puppet::Util::FileLocking.should respond_to(:readlock)
    end

    it "should have a module method for getting a write lock on files" do
        Puppet::Util::FileLocking.should respond_to(:writelock)
    end

    it "should have an instance method for getting a read lock on files" do
        FileLocker.new.private_methods.should be_include("readlock")
    end

    it "should have an instance method for getting a write lock on files" do
        FileLocker.new.private_methods.should be_include("writelock")
    end

    describe "when acquiring a read lock" do
        it "should use a global shared mutex" do
            sync = mock 'sync'
            sync.expects(:synchronize).with(Sync::SH)
            Puppet::Util.expects(:sync).with("/file").returns sync

            Puppet::Util::FileLocking.readlock '/file'
        end

        it "should use a shared lock on the file" do
            sync = mock 'sync'
            sync.expects(:synchronize).yields
            Puppet::Util.expects(:sync).with("/file").returns sync

            fh = mock 'filehandle'
            File.expects(:open).with("/file").yields fh
            fh.expects(:lock_shared).yields "locked_fh"

            result = nil
            Puppet::Util::FileLocking.readlock('/file') { |l| result = l }
            result.should == "locked_fh"
        end
    end

    describe "when acquiring a write lock" do
        before do
            @sync = mock 'sync'
            Puppet::Util.stubs(:sync).returns @sync
            @sync.stubs(:synchronize).yields
        end

        it "should fail if the parent directory does not exist" do
            FileTest.expects(:directory?).with("/my/dir").returns false

            lambda { Puppet::Util::FileLocking.writelock('/my/dir/file') }.should raise_error(Puppet::DevError)
        end

        it "should use a global exclusive mutex" do
            sync = mock 'sync'
            sync.expects(:synchronize).with(Sync::EX)
            Puppet::Util.expects(:sync).with("/file").returns sync

            Puppet::Util::FileLocking.writelock '/file'
        end

        it "should use any specified mode when opening the file" do
            File.expects(:open).with("/file", "w", :mymode)

            Puppet::Util::FileLocking.writelock('/file', :mymode)
        end

        it "should use the mode of the existing file if no mode is specified" do
            File.expects(:stat).with("/file").returns(mock("stat", :mode => 0755))
            File.expects(:open).with("/file", "w", 0755)

            Puppet::Util::FileLocking.writelock('/file')
        end

        it "should use 0600 as the mode if no mode is specified and the file does not exist" do
            File.expects(:stat).raises(Errno::ENOENT)
            File.expects(:open).with("/file", "w", 0600)

            Puppet::Util::FileLocking.writelock('/file')
        end

        it "should create an exclusive file lock" do
            fh = mock 'fh'
            File.expects(:open).yields fh
            fh.expects(:lock_exclusive)

            Puppet::Util::FileLocking.writelock('/file')
        end

        it "should allow the caller to write to the locked file" do
            fh = mock 'fh'
            File.expects(:open).yields fh

            lfh = mock 'locked_filehandle'
            fh.expects(:lock_exclusive).yields(lfh)

            lfh.expects(:print).with "foo"

            Puppet::Util::FileLocking.writelock('/file') do |f|
                f.print "foo"
            end
        end
    end
end
