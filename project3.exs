defmodule Project3 do
	  [numNodes, numRequests] = System.argv
	  #extracted arguments from commandline
	  numNodes = String.to_integer(numNodes)
	  numRequests = String.to_integer(numRequests)

	  Proj3.main(numNodes, numRequests)
	  
	  # IO.puts("Start1")
end
