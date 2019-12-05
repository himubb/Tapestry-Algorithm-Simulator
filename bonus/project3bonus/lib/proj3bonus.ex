defmodule Proj3bonus do
  	def main(numNodes, numRequests, errorNodesPercent) do
	  GenServer.start_link(Tapestrybonus, [numNodes, numRequests,errorNodesPercent], name: :Master)
	end

end
