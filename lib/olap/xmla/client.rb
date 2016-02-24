require 'savon'
require 'olap/xmla/response'

class Olap::Xmla::Client

  attr_reader :data_source, :catalog, :client

  def initialize server, data_source, catalog, options

    @catalog = catalog
    @data_source = data_source
    @verbose = options[:verbose]
    @client = Savon.client do
      endpoint server
      namespace "urn:schemas-microsoft-com:xml-analysis"
      open_timeout (options[:open_timeout] || 60)
      read_timeout (options[:read_timeout] || 300)
    end
  end

  # Executes multiple MDX queries as a batch
  #
  # Arguments:
  #  * +mdx_requests+ - Collection of MDX requests
  #  * +parameters+ - Map of parameters to substitute in MDX request, optional
  #
  def batch mdx_requests, parameters = {}
    mdx_requests.collect{|mdx|
      request mdx, parameters
    }
  end

  # Execute MDX queries, substituting parameters in the query
  #
  # Arguments:
  #  * +mdx_request+ - MDX request as a string, required
  #  * +parameters+ - Map of parameters to substitute in MDX request, optional
  #
  # Example:
  #
  #  client.request 'SET [~ROWS_Date] AS {[DateTime].[Date].[Date].[%DATE%]}', {'%DATE%' => '20150530'}
  #    will execute actual MDX: SET [~ROWS_Date] AS {[DateTime].[Date].[Date].[20150530]}
  #
  #
  def request mdx_request, parameters = {}

    mdx = mdx_request.clone
    puts mdx if @verbose

    parameters.each{|k,v|
      mdx.gsub!(k,v)
    }

    ops = client.operation('Execute')
    p = { 'wsdl:PropertyList' => {'wsdl:DataSourceInfo' => data_source,
                                 'wsdl:Catalog' => catalog,
                                 'wsdl:Format' => 'Multidimensional',
                                 'wsdl:AxisFormat'=> 'TupleFormat'} }


    r = ops.call(  message: {'wsdl:Command' =>  { 'wsdl:Statement' => mdx}, 'wsdl:Properties' => p })

    unless r.success?
      raise "Error executing #{mdx} in #{catalog} #{data_source}: #{r.http_error} #{r.soap_fault}"
    end

    Olap::Xmla::Response.new r.body[:execute_response][:return][:root], mdx

  end



end



