require 'json'

#
# Invocations should look like:
#
# 	jsonlookup("key", "default_value", "json_file)
#
module Puppet::Parser::Functions
  newfunction(:jsonlookup, 
  :type => :rvalue,
  :doc => "Similar to extlookup. s/jsonlookup/jsonlookup/ s/csv/json/.") do |args|

  key = args[0]
  default  = args[1]
  datafile = args[2]

  raise Puppet::ParseError, ("jsonlookup(): wrong number of arguments (#{args.length}; must be <= 3)") if args.length > 3


  # Parse out the query string, if there is one
  query_key = nil
  query_value = nil
  if query_string
    components = key.split('=')
    if components.length == 2
      query_key = components[0]
      query_value = components[1]
    end
  end

  jsonlookup_datadir = lookupvar('jsonlookup_datadir')
  jsonlookup_precedence = Array.new

  jsonlookup_precedence = lookupvar('jsonlookup_precedence').collect do |var|
    var.gsub(/%\{(.+?)\}/) do |capture|
      lookupvar($1)
    end
  end

  datafiles = Array.new

  # if we got a custom data file, put it first in the array of search files
  if datafile != ""
    datafiles << jsonlookup_datadir + "/#{datafile}.json" if File.exists?(jsonlookup_datadir + "/#{datafile}.json")
  end

  jsonlookup_precedence.each do |d|
    datafiles << ymllookup_datadir + "/#{d}.json"
  end

  desired = nil

  # The desired effect here:
  # - If the json file is a list, we return all elements in the list
  #   that contain the key
  # - If the json file is a dict, we return the element at the key
  # - If the json file is a list and the key is a query string, we return
  #   all the elements that match the key,value pair
  datafiles.each do |file|
    if desired.nil?
      begin
        result = JSON.parse(File.open(file, "r").read)
        if result.kind_of? Hash
          desired = result[key]
        elsif result.kind_of? Array
          if query_key and query_value
            desired = result.select{ |e| e[key] and e[key] == value}
          elsif result.has_key?(key)
            desired = result[key]
          end
        end
      rescue
	# If we can't open the file we will fail here.
        # probably want to do something more specific.
        false
      end
    end
  end

  desired || default or raise Puppet::ParseError, "No match found for '#{key}' in any data file during jsonlookup()"
  end
end

