defmodule Project3bonus do
	  [numNodes, numRequests, errorNodesPercent] = System.argv
	  #extracted arguments from commandline

	  	numNodes = String.to_integer(numNodes)
		numRequests = String.to_integer(numRequests)
		errorNodesPercent=String.to_integer(errorNodesPercent)
	  	Proj3bonus.main(numNodes, numRequests, errorNodesPercent)
	
end
