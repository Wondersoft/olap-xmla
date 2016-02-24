class Olap::Xmla::Response

  attr_reader :mdx, :response

  def initialize response, mdx
    @response = response
    @mdx = mdx
  end

  # Returns true if the response has any data
  def has_data?
    not response[:cell_data][:cell].empty?
  end

  # Collection of measures in response
  #
  # *  +:name+  the name of measure
  # *  +:caption+ display name of measure
  #
  def measures
    response[:axes][:axis][0][:tuples][:tuple].collect{|m|
      {
          name: m[:member][:u_name],
          caption: m[:member][:caption]
      }
    }
  end

  # Collection of dimensions in response
  #
  # *  +:name+  the name of dimension
  #
  def dimensions
    response[:olap_info][:axes_info][:axis_info][1][:hierarchy_info].collect{|m|
      {
          name: m[:@name]
      }
    }
  end


  # Collection of result rows
  # * rownum  number of row ( 1... N)
  # * labels - array of tuples per the row
  #      value - the value of tuple
  #      name - the name of tuple
  # *  values - the values array
  #      measure - metric name
  #      value - metric value
  #      fmt_value - formatted metric value
  #      colnum - column number ( 1..N)
  def rows

    return [] unless response[:cell_data]

    measures = [response[:axes][:axis][0][:tuples][:tuple]].flatten
    cells = [response[:cell_data][:cell]].flatten

    cell_ordinal = 0
    cell_index = 0
    rownum = 0

    [response[:axes][:axis][1][:tuples][:tuple]].flatten.collect{ |tuple|
      rownum += 1
      colnum = 0
      tuple_member = [tuple[:member]].flatten
      {  rownum: rownum,
         labels: tuple_member.collect{|member|
           value = member[:caption]
           value = nil if value=='#null'
           {value: value, name: member[:@hierarchy]}
         },
         values: measures.collect{|m|

           colnum += 1

           if (cell=cells[cell_index]) && cell[:@cell_ordinal].to_i==cell_ordinal
             cell_index += 1
             cell_ordinal += 1
             { colnum: colnum, measure: m[:member][:u_name], value: cell[:value], fmt_value: cell[:fmt_value]}
           else
             cell_ordinal += 1
             { colnum: colnum, measure: m[:member][:u_name], value: nil, fmt_value: nil}
           end

         }

      }
    }

  end

  # query a colum of the result
  #
  # Example:
  #
  # >> response.column_values 1
  #  => [30.0, 1025.0, 884.0, 543.0,...
  #
  def column_values column_num

    rows.collect{|row|
      row[:values].detect{|value|
        value[:colnum]==column_num
      }[:value].to_f
    }

  end

  # Aggregate result by one of the columns
  def column_values_aggregate dimension_aggr_index = 0

    result = []
    index = {}

    rows.each{|row|
      label = row[:labels][dimension_aggr_index]

      if i = index[label]
        for j in 0..result[i][:values].count-1
          result[i][:values][j] += row[:values][j][:value].to_f
        end
      else
        index[label] = result.count
        result << {
            rownum: result.count + 1,
            label: label,
            values: row[:values].collect{|v| v[:value].to_f }
        }
      end
    }

    result
  end

  # Convert the response to hash
  # keys of hash are values of tuples
  # values of hash are values of metrics
  #
  # Example:
  #
  #  response.to_hash
  #  => {["2014", "05/11/2014"]=>[30.0, 27.0, 0.0], ["2014", "06/11/2014"]=>[1025.0, 688.0, 73.0]
  #
  def to_hash
    Hash[rows.collect{|row|
           [
               row[:labels].collect{|l| l[:value].nil? ? nil : l[:value] },
               row[:values].collect{|l| (l.nil? || l[:value].nil?) ? 0.0 : l[:value].to_f },
           ]

         }]
  end

end
