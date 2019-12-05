Project members:
------------------------
Himavanth Boddu(32451847)
Shubham Saoji(26364957)

1. Problem Definition
We talked extensively in class about the overlay networks and how they can be used to
provide services. The goal of this project is to implement in Elixir using the actor model
the Tapestry Algorithm and a simple object access service to prove its usefulness. The
specification of the Tapestry protocol can be found in the paper-
Tapestry: A Resilient Global-Scale Overlay for Service Deployment by Ben Y. Zhao, Ling
Huang, Jeremy Stribling, Sean C. Rhea, Anthony D. Joseph and John D. Kubiatowicz. Link
to paper- https://pdos.csail.mit.edu/~strib/docs/tapestry/tapestry_jsac03.pdf. You can
also refer to Wikipedia page: https://en.wikipedia.org/wiki/Tapestry_(DHT) . Here is
other useful link: https://heim.ifi.uio.no/michawe/teaching/p2p-ws08/p2p-5-6.pdf .
Here is a survey paper on comparison of peer-to-peer overlay network schemes-
https://zoo.cs.yale.edu/classes/cs426/2017/bib/lua05survey.pdf.

The overall goal of this project is to implement Tapestry algorithm and calculate the maximum hops made while routing takes place for numNodes number of nodes and numRequest number of requests.

Instruction to run code:
------------------------
mix run project3.exs numNodes numRequests
Output displays number of max hops among all requests made.

Working:
------------------------
The implementation of Tapestry Algorithm is working correctly and maximum hops is returned. All requirements mentioned in problem statement have been implemented.

We have encoded each node number using SHA-1 algorithm which generates 160 bits out of which we use 40 bits(10 characters) and used hex value of it in get_hash(nodeId) function defined by us. We create routing table using ets (The table name for each routing table is an atom in format node id preceded by N and each table is private i.e. read/write function can be performed only by node for which table is created)for each node which contains 10 rows and 16 columns(0-F) where row corresponds to the index of the character matched between source and target and column value corresponds to the first unmatched character node id. If no such match is found then that entry is filled as nil. We create this for 80% of the nodes given in numNodes.

For 80% of nodes, routing table is created as soon as process is spawned. The remaining 20% are added using dynamic node join which computes the routing tables for themselves and send a broadcast message using handle cast to all the nodes except itself so that other nodes are notified about addition of new node in system and they modify/update their routing table accordingly. This is done by comparing the nodeId value with source id and difference is taken, the node with lowest difference is selected while updating the table.

To calculate maximum hops we first select a node as source and numRequest number of other nodes(excluding the source) .To send request from source to a destination listed in destination list, we first check if the destination node is present in the routing table of the source node. If it is present then it will be completed in one hop else it will search for the nearest node to the destination which is available in the routing table using count_hops() function. Whenever a request is forwarded to next node, we increment the hop count in hops_table( an ets table which stores hop count for all numRequest number of destinations) .Then we compute hops taken to arrive to the destination node and output the maximum hops taken in this process.

Bonus part is also submitted and report is in bonus part of project.


Largest Problem solved:
-------------------------
numNodes: 10,000
numRequests: 200
maxHopCount=5
