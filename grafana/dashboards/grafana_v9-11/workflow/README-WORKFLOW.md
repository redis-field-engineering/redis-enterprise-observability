# Workflow Dashboards

Workflow dashboards make it easy to visit any type of metrics by simply clicking a link. 
Some dashboards have rows of panels that themselves have links. An example would be to 
view all the databases in a given cluster and then review the latency statistics in detail
by clicking the latency summary pane for a specific dashboard.

The top-level software dashboard present basic cluster metrics; memory, latency, key count, and operations/sec.
Following those displays it presents a list of databases with links to the database dashboard, 
a list of nodes with links to the node dashboard, a list of nodes with links to the proxy 
thread dashboard, and lastly a list of nodes with links to the proxy network dashboard. 
The top-level cloud dashboard substitutes a list of nodes with links to the active-active dashboard 
for the node dashboard.

#### Cluster - Software
* [Cluster](redis-software-cluster_v9-11.json)
* [Databases](databases/redis-software-cluster-databases_v9-11.json)
* [Nodes](nodes/redis-software-cluster-nodes_v9-11.json)
* [Proxy Thread](redis-software-proxy-thread_v9-11.json)
* [Proxy Network](redis-software-proxy-network_v9-11.json)

#### Cluster - Cloud
* [Cluster](redis-cloud-cluster_v9-11.json)
* [Databases](databases/redis-software-cluster-databases_v9-11.json)
* [Active-Active](redis-software-active-active_v9-11.json)
* [Proxy Thread](redis-software-proxy-thread_v9-11.json)
* [Proxy Network](redis-software-proxy-network_v9-11.json)

#### Databases
* [Database-CPU](databases/redis-software-cluster-database-cpu_v9-11.json)
* [Database-Latency](databases/redis-software-cluster-database-latency_v9-11.json)
* [Database-Memory](databases/redis-software-cluster-database-memory_v9-11.json)
* [Database-Requests](databases/redis-software-cluster-database-requests_v9-11.json)

#### Nodes
* [Node-CPU](nodes/redis-software-cluster-node-cpu_v9-11.json)
* [Node-Latency](nodes/redis-software-cluster-node-latency_v9-11.json)
* [Node-Memory](nodes/redis-software-cluster-node-memory_v9-11.json)
* [Node-Requests](nodes/redis-software-cluster-node-requests_v9-11.json)
