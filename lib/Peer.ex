defmodule Peer do
	use GenServer

	def start_link do
    	GenServer.start_link(__MODULE__,[])
  	end

	def init([_num, _l]) do
    # IO.puts("i1 " <> num)
		
		{:ok, []}
	end


def compare_elements(is_val, element,num) do
  {is_val1,_} = Integer.parse(is_val,16)
  {num1,_} = Integer.parse(num,16)
  {element1,_} = Integer.parse(element,16)
  # IO.puts(is_val)
  # IO.puts(num)
  difference1=abs(is_val1-num1)
  # IO.puts("difference1")
  # IO.puts(difference1)
  difference2=abs(element1 - num1)
  # IO.puts("difference2")
  # IO.puts(difference2)

  temp = if difference1>difference2 do
   element
  else
    is_val
  end
  temp
end


	def setvalue(table_name, row, col, value) do
     :ets.insert(table_name, {"#{row}" <> "-" <> col, value})     
  end

  def print_table(m, table_name) do
    # IO.puts("checkpoint10")
    # IO.inspect(table_name)

    for row <- 0..m-1 do
      for col <- ["0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"] do
        :ets.lookup(table_name, "#{row}" <> "-" <> col)
        # IO.inspect(val)
      end
    end
  end



	def getvalue(table_name, row, col) do
	 [{_, ret_val}] = :ets.lookup(table_name, "#{row}" <> "-" <> col)
   ret_val
	end


  def update_table(i, element, comparison_list, m, table_name, num) when i<m do
        # IO.puts(String.slice(element,0,i+1))
        # IO.puts(Enum.at(comparison_list, m - 1 - i))
        var = String.slice(element,0,i+1) == Enum.at(comparison_list, m - 1 - i)
        # IO.inspect(var)
        if var==false do
          row = i
          # IO.puts("Success")
          col = String.at(element, row)
          # IO.puts(num <> " " <> element)
          # IO.puts("row" <> "#{row}")
          # col = Integer.parse(col, 16) |> elem(0)
          # IO.puts("--------------------------------")
          is_val = getvalue(table_name, row, col) 
          # IO.puts(is_val)

          if is_val != nil do
              # IO.puts("checkpoint22" <> "Element: " <> element <> "     Nums: " <> num )
              # IO.inspect(is_val)
              x=compare_elements(is_val, element,num)
              # IO.puts("cchpt")
              if x != is_val do
                setvalue(table_name, row, col, x)
                # IO.puts("jamaude")
                # IO.inspect(getvalue(table_name, row, col))
              end
          else
            # IO.puts("checkpoint1")
            setvalue(table_name, row, col, element)
            # IO.puts("jamaude")
            # IO.inspect(getvalue(table_name, row, col))
              # print_table(m, table_name)
          end
        else
          update_table(i+1, element, comparison_list, m, table_name, num)
        end
  end


  def count_hops(i, d_node, comparison_list, m, table_name, source_node, counter_table) when i<m do
        # IO.puts(String.slice(element,0,i+1))
        # IO.puts(Enum.at(comparison_list, m - 1 - i))
        var = String.slice(d_node,0,i+1) == Enum.at(comparison_list, m - 1 - i)
        # IO.inspect(var)
        if var==false do
          row = i
          # IO.puts("Success")
          col = String.at(d_node, row)
          # IO.puts(num <> " " <> element)
          # IO.puts("row" <> "#{row}")
          # col = Integer.parse(col, 16) |> elem(0)
          # IO.puts("--------------------------------")
          is_val = getvalue(table_name, row, col) 
          # IO.puts(is_val)
          [{_, counter}] = :ets.lookup(counter_table, d_node)
          counter = counter + 1
          :ets.insert(counter_table, {d_node, counter})
            if is_val != d_node do
              GenServer.cast(get_process_name(is_val), {:hops, is_val, d_node, counter_table})
            end
        else
          count_hops(i+1, d_node, comparison_list, m, table_name, source_node, counter_table)
        end
  end



  def handle_cast({:hops, source_node, d_node, counter_table}, _state) do
    # IO.puts("Partial Success")
    table_name = get_table_name(source_node)
    m = String.length(source_node)
    comparison_list = get_comparison_list(m, source_node)
    count_hops(0, d_node, comparison_list, m, table_name, source_node, counter_table)
    {:noreply,[]}
  end


  def handle_cast({:print_table, num}, _state) do
    # IO.puts("Partial Success")
    get_routing_table(num)
    {:noreply,[]}
  end

  def handle_cast({:modify_table, num, new_node}, _state) do
    # IO.puts("Partial Success")
    m = String.length(num)
    comparison_list = get_comparison_list(m, num)
    table_name = get_table_name(num)
    update_table(0, new_node, comparison_list, m, table_name, num)

    {:noreply,[]}
  end


  def handle_cast({:initiate, num, l}, _state) do
    #create Routing Table
    #h is no of characters of node id
    m = String.length(num)
    # list=List.duplicate(nil, 16)|> List.duplicate(m)
    t_name = get_table_name(num)
    table_name = :ets.new(t_name, [:set, :private, :named_table])
    for row <- 0..m-1 do
      for col <- ["0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"] do
        # IO.puts("Checkpt")
        :ets.insert(table_name, {"#{row}" <> "-" <> col, nil})
        # IO.inspect(v)
      end
    end

    # print_table(m, table_name)
    # IO.inspect(table_name)
    l = l -- [num]

    # IO.puts(num)
    comparison_list = get_comparison_list(m, num)
    # IO.inspect(comparison_list)

    # IO.puts("num " <> num)
    # IO.inspect(l)
    # IO.puts("num " <> num)


    for element <- l do
      # IO.puts("element " <> element)
      update_table(0, element, comparison_list, m, table_name, num)
      
    end
    
    {:noreply,[]}
  end


  def get_comparison_list(m, num) do
    comparison_list = []
    comparison_list = for z1 <- m..1 do
      comparison_list = [String.slice(num, 0, z1)] ++ comparison_list
      comparison_list
    end
    List.flatten(comparison_list)
  end

  def get_routing_table(num) do
    # IO.puts("checkpoint2")
    m = 10
    table_name = get_table_name(num)
    print_table(m, table_name)
  end



  def get_process_name(num) do    
    ("Elixir.P" <> num) |> String.to_atom()
  end


  def get_table_name(num) do    
    ("Elixir.N" <> num) |> String.to_atom()
  end

end