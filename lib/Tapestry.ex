defmodule Tapestry do
	use GenServer



	def init([numNodes, numRequests]) do
		start_proc(numNodes, numRequests)
    	{:ok, numNodes}
  	end

	def start_proc(numNodes, numRequests) do
		numNodes_hex = Integer.to_string(numNodes, 16)
		m = String.length(numNodes_hex)
		counter_table = :ets.new(:hops_table, [:set, :public, :named_table])

		max_nodes = :math.pow(16, m) |> trunc()
		
		#add_nodes is the number of new nodes to be added
		add_nodes = ceil(0.2*numNodes) |> trunc()

		l = []
		l = for z <- 0..max_nodes-1 do
			l ++ z
		end
		# IO.inspect(l)

		l = Enum.shuffle(l)
		l = Enum.slice(l, 0, numNodes) |> Enum.sort() 
		# IO.inspect(l)
		l = Enum.map(l, fn x ->  get_hash(Integer.to_string(x)) end)
		
		
		new_elements_list = Enum.slice(l, -add_nodes..-1) 
		current_elements_list = l -- new_elements_list

		:ets.insert(counter_table, {"curr_list", current_elements_list})
		# IO.inspect(length(l))
		# IO.inspect(length(current_elements_list))
		# IO.inspect(length(new_elements_list))

		
		
		for num <- current_elements_list do
			# IO.puts("i " <> num)
      		GenServer.start_link(Peer, [num, current_elements_list], name: get_process_name(num))
      		GenServer.cast(get_process_name(num), {:initiate, num, current_elements_list})
		end
		
		

		:timer.sleep(1000)
		
		#for add_nodes number of new nodes routing table of previously set nodes needs to be modified
		for new_node <- new_elements_list do
			dynamic_node_join(counter_table, new_node)
		end


		#route from source to destination and calculate maximum hops
		
		all_nodes = l
		source_node = Enum.random(all_nodes)
		all_nodes = all_nodes -- [source_node]
		destination_list = Enum.take_random(all_nodes, numRequests)

		for i <- destination_list do
			:ets.insert(counter_table, {i, 0})
		end

		for d_node <- destination_list do
			GenServer.cast(get_process_name(source_node), {:hops, source_node, d_node, counter_table})
		end
		:timer.sleep(1000)
		temp = 0
		temp = for i <- destination_list do
			[{_, val}] = :ets.lookup(counter_table, i)
			# IO.inspect()
			:timer.sleep(100)
			# IO.inspect(val)
			temp = if temp <= val do
				val
			else
				temp

			end
			temp
		end
		# IO.inspect(temp)
		IO.puts("#{Enum.max(temp)}")






		# IO.puts("Getting result")
		# pid = Process.whereis(Peer.get_process_name(test_node))
		# IO.inspect(Peer.get_process_name(test_node))
		# IO.inspect(Process.alive?(pid))
		# GenServer.cast(Peer.get_process_name(test_node), {:print_table, test_node})



	end



	def dynamic_node_join(counter_table, new_node) do
		[{_, current_elements_list}] = :ets.lookup(counter_table, "curr_list")
			
			for num <- current_elements_list do
				GenServer.cast(get_process_name(num), {:modify_table, num, new_node})
			end
			current_elements_list = current_elements_list ++ [new_node]
			:ets.insert(counter_table, {"curr_list", current_elements_list})
			:timer.sleep(200)
			GenServer.start_link(Peer, [new_node, current_elements_list], name: get_process_name(new_node))
      		GenServer.cast(get_process_name(new_node), {:initiate, new_node, current_elements_list})


	end

#enter input in string as nodeId to get 10 letter SHA encrpyed hex code
	def get_hash(nodeId) do
    	remain_digest = 160 - 40
    	<<_::size(remain_digest), used::40>> = :crypto.hash(:sha, nodeId)
	    truncated=<<used::40>>
	    hashed_nodeId= String.downcase(Base.encode16(truncated))
	    # hashed_nodeId=String.slice(hashed_nodeId,0,m)
	    # hashed_nodeId = if Enum.member?(l, hashed_nodeId) do
	    # 	get_hash(nodeId, l)
	    # else
	    # 	hashed_nodeId
	    # end
	    hashed_nodeId
  	end





	def get_process_name(num) do		
		("Elixir.P" <> num) |> String.to_atom()
	end







end