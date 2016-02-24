require "olap/xmla/version"
require "olap/xmla/client"

module Olap

  #
  # Connects to XMLA[https://en.wikipedia.org/wiki/XML_for_Analysis] server and executes MDX[https://en.wikipedia.org/wiki/MultiDimensional_eXpressions] queries
  #
  module Xmla

    @@connect_options = {}

    # Configure the default options to connect to XMLA server
    # Can be optionally used to setup connection options in one place in application,
    #
    # Example:
    #   >> Olap::Xmla.default_options = {server: 'http://your-olap-server', datasource: 'your-datasource', catalog: 'your-catalog'}
    #   >> Olap::Xmla.client.request mdx
    #   => #<Olap::Xmla::Response:0x000001035b9510 @response={ ...
    #
    # Look client connect_options for the list of options to be specified
    #
    def self.default_options= options
      @@connect_options = options
    end

    # Create a client, which can be used then to execute MDX queries
    #
    # Example:
    #   >> client = Olap::Xmla.client(server: 'http://your-olap-server', datasource: 'your-datasource', catalog: 'your-catalog')
    #   >> response = client.request mdx
    #   => #<Olap::Xmla::Response:0x000001035b9510 @response={ ...
    #
    # ==== connect_options
    #
    #  * +:server+ - URL to connect to XMLA server (required)
    #  * +:datasource+ - the name of datasource (required)
    #  * +:catalog+ - the name of catalog (required)
    #  * +:open_timeout+ - open timeout to connect to XMLA server, optional, default is 60 sec
    #  * +:read_timeout+ - open timeout to read data from XMLA server, optional, default is 300 sec
    #  * +:verbose+ - if set to true, write MDX requests to console. Default is false
    #
    #
    def self.client connect_options = {}
      options = @@connect_options.merge connect_options
      raise "Connect options must define :server, :datasource and :catalog options" unless
          options[:server] && options[:datasource] && options[:catalog]
      Olap::Xmla::Client.new options[:server], options[:datasource], options[:catalog], options
    end

  end
end
