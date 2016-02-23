require 'spec_helper'


connection_config = YAML.load File.read 'spec/.config.yaml'

describe 'Test MDX queries' do

  it 'should request mdx' do

    client = Olap::Xmla.client connection_config

    mdx= "WITH SET [~ROWS_YearByDay] AS " +
          "{[DateTime].[YearByDay].[Year].Members} " +
        "SET [~ROWS_Date] AS " +
        "    {[DateTime].[Date].[Date].Members} " +
        "SELECT " +
        "NON EMPTY {[Measures].[Slots], [Measures].[Clicks], [Measures].[Conversions]} ON COLUMNS, " +
        "NON EMPTY NonEmptyCrossJoin([~ROWS_YearByDay], [~ROWS_Date]) ON ROWS " +
        "FROM [Ad Serving]"

    response = client.request mdx

    expect(response.has_data?).to be true

    expect(response.measures.count).to eq 3
    expect(response.measures[0][:name]).to eq '[Measures].[Slots]'
    expect(response.measures[1][:name]).to eq '[Measures].[Clicks]'

    expect(response.dimensions.count).to eq 2

    expect(response.dimensions[0][:name]).to eq 'YearByDay'
    expect(response.dimensions[1][:name]).to eq 'Date'

    expect(response.rows.count).to be > 100

    expect(response.rows[0][:rownum]).to eq 1

    expect(response.rows[0][:labels].size).to eq 2
    expect(response.rows[0][:labels][0][:name]).to eq 'YearByDay'
    expect(response.rows[0][:labels][1][:name]).to eq 'Date'

    expect(response.rows[0][:values].size).to eq 3

    expect(response.rows[0][:values][0][:colnum]).to eq 1
    expect(response.rows[0][:values][0][:measure]).to eq '[Measures].[Slots]'
    expect(response.rows[0][:values][0][:value]).to_not be_nil

  end

  it 'should use default connect' do

    Olap::Xmla.default_options = connection_config

    client = Olap::Xmla.client

    mdx= "WITH SET [~ROWS_YearByDay] AS " +
        "{[DateTime].[YearByDay].[Year].Members} " +
        "SET [~ROWS_Date] AS " +
        "    {[DateTime].[Date].[Date].Members} " +
        "SELECT " +
        "NON EMPTY {[Measures].[Slots], [Measures].[Clicks], [Measures].[Conversions]} ON COLUMNS, " +
        "NON EMPTY NonEmptyCrossJoin([~ROWS_YearByDay], [~ROWS_Date]) ON ROWS " +
        "FROM [Ad Serving]"

    response = client.request mdx

    expect(response.has_data?).to be true

  end


end