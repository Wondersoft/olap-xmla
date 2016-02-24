# Olap::Xmla

The gem connects to OLAP database using XMLA interface and executes MDX queries.

Can be used in Ruby or Rails applications to display and analyse data from OLAP databases.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'olap-xmla'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install olap-xmla

## Usage

Using the gem is very simple, only basic knowledge on OLAP is required.

### Connecting to server

To use the gem, you need to know the connection requisites to connect to XMLA server:

1. Server URL ( typically, http: or https: URL )
2. Datasource and catalog names. You can check them in your XMLA server configuration

Connecting to the server and executing MDX are straightforward:

```ruby
require 'olap/xmla'

client = Olap::Xmla.client({
            server: 'http://your-olap-server',
            datasource: 'your-datasource',
            catalog: 'your-catalog'})
response = client.request 'your-mdx-here'
```

### Configuration in Rails

If you are using this gem in Rails application, which uses just single OLAP data source,
you can simplify the code by pre-configuring the XMLA connection.

Create a file olap.rb in config/initializers directory with the following content:

```ruby
Olap::Xmla.default_options= { server: 'http://your-olap-server',
                                datasource: 'your-datasource',
                                catalog: 'your-catalog'}
```

Then in Rails application code you can simply do:

```ruby
response = Olap::Xmla.client.request 'your-mdx-here'
```

### Querying MDX

The gem does not parse MDX, just passes it to XMLA server.

However, it can do substituting parameters in the query:

```ruby
MDX_QUERY = 'SET [~ROWS_Date] AS {[DateTime].[Date].[Date].[%DATE%]}'

Olap::Xmla.client.request MDX_QUERY, {'%DATE%' => '20150530'}
```

This allows to store MDX queries in constants, while execute them with dynamic parameters.
Note, that you should never use these parameters directly from Rails request, as
this may create security breach!

### Response


You may use the response to render the results to user, or post-process it to analyse the data
The following methods can be used to request the meta-data and data from the response:

```ruby
response = client.request(mdx)


# Meta - data of the response
response.measures  #  array of the columns definitions ( :name / :caption )
response.dimensions # array of the rows definitions ( :name )

# Response data
response.rows # rows of the response
response.to_hash # response as a hash
response.column_values(column_num) # just one column of the response

```

### Example: rendering a table on web page

Typically, the request should be done in controller action, as simple as:

OlapController.erb
```ruby
def index
@response = Olap::Xmla.client.request 'WITH SET ... your mdx goes here';
%>
```

and in the HTML Erb view you use iteration over the response as:

index.html.erb
```ruby
<table>
  <thead><tr>
        <% for dim in @response.dimensions %><th><%= dim[:name] %></th><% end %>
        <% for m in @response.measures %><th><%= m[:caption] %></th><% end %>
    </tr></thead>
  <tbody>
    <% for row in @response.rows %>
    <tr>
       <% for label in row[:labels] %>
        <td><%= label[:value] %></td>
       <% end %>
      <% for value in row[:values] %>
          <td><%= value[:fmt_value] || value[:value] %></td>
      <% end %>
    </tr>
    <% end %>
  </tbody>
</table>
```

Have fun!

## Contributing

1. Fork it ( https://github.com/Wondersoft/olap-xmla/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
