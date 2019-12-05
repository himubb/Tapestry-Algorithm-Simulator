defmodule Proj3 do
 #  	def start(_type, _args) do
	#   [numNodes, numRequests] = System.argv
	#   #extracted arguments from commandline

	#   numNodes = String.to_integer(numNodes)
	#   numRequests = String.to_integer(numRequests)
	#   # IO.puts("Start1")
	#   GenServer.start_link(Tapestry, [numNodes, numRequests], name: :Master)	 
	# end
	def main(numNodes, numRequests) do
		GenServer.start_link(Tapestry, [numNodes, numRequests], name: :Master)
	end

  
end
