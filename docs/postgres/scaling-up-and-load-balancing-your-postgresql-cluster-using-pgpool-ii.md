
# Scaling up and load balancing your PostgreSQL Cluster using Pgpool-II

PostgreSQL’s speed, robustness and security makes it suitable for 99% of the new-age applications. Today, let’s deep dive into how you can enable scalability and load balancing of your PostgreSQL cluster using Pgpool-II. When your [PostgreSQL](https://www.ashnik.com/postgresql/) starts to receive more transactions and needs to scale up, consider using a Load Balancer for the PostgreSQL clusters. It helps enhance your database query retrieval.

![Pgpool II blogImg 1](./img/pgpool-II-blogImg-1.png "Scaling up and load balancing your PostgreSQL Cluster using Pgpool-II 2")

## What Is PGPOOL-II?

[Pgpool-II](https://www.pgpool.net/docs/42/en/html/intro-whatis.html) is a middleware that works between PostgreSQL servers and a PostgreSQL database client. It is distributed under a license similar to BSD and MIT. Let’s take a look at the features it provides:

-   **Connection Pooling**
    
    Pgpool-II saves connections to the PostgreSQL servers, and reuses them whenever a new connection with the same properties (i.e. username, database, protocol version) comes in. It reduces connection overhead, and improves the system’s overall throughput.
    
-   **Load Balancing**
    
    If a database is replicated, executing a SELECT query on any server will return the same result. Pgpool-II takes an advantage of the replication feature to reduce the load on each PostgreSQL server by distributing SELECT queries among multiple servers, thereby improving the system’s overall throughput. At best, the performance improves proportionally to the number of PostgreSQL servers. Load balance works best in a situation where there are a lot of users executing many queries at the same time.
    
-   **Limiting Exceeding Connections**
    
    There is a limit on the maximum number of concurrent connections with PostgreSQL, and connections that get rejected after this threshold. Setting the maximum number of connections, however, increases resource consumption and effects system performance. Pgpool-II also has a limit on the maximum number of connections, but any extra connection request gets queued instead of returning an error immediately.
    
-   **In Memory Query Cache**
    
    In memory query cache allows to save a pair of SELECT statements and its results. If an identical SELECTs comes in, Pgpool-II returns the value from the cache. Since no SQL parsing nor access to PostgreSQL are involved, hence using in memory cache is extremely fast. On the other hand, it might be slower than the normal path in some cases, because it adds some overhead of storing cache data.
    

Pgpool-II communicates to PostgreSQL’s backend and frontend protocols, and relays messages between a backend and a frontend. Therefore, a database application (frontend) thinks that this is the actual PostgreSQL server, and the server (backend) sees Pgpool-II as one of its clients. Also, since the middleware is transparent to both the server and the client, an existing database application can be used with Pgpool-II almost without a change to its sources.

## How Load Balancing Works Within the PGPOOL-II

![Pgpool II blogImg 2](https://ashnik-images.s3.amazonaws.com/prod/wp-content/uploads/2022/06/15194808/Pgpool-II-blogImg-2.png "Scaling up and load balancing your PostgreSQL Cluster using Pgpool-II 3")

Pgpool-II located in between the PostgreSQL client and server, is capable of understanding the PostgreSQL backend and frontend protocols relaying client requests to the server. This happens because the middleware has adopted a parser from PostgreSQL, which can perform the way of parsing client queries. It routes the query as follows:

1.  Pgpool-II accepts client request
2.  Pgpool-II parses the query request in the background
3.  If the query results in any Delete/Update/Insert transaction, Pgpool-II sends it to the Master DB
4.  If the query results in any Select transactions, Pgpool-II sends it to the selected Load Balance node from all the available PostgreSQL servers related to **_backend_weight_** configuration parameter

Balancing in Pgpool-II, you should enable the load_balance_mode and backend_weight parameters. As mentioned in the previous section, to perform load balancing Pgpool-II selects a load balancing node and routes the READ queries to that node. The load balancing node is randomly selected according to the weight specified in backend_weight parameter.

For example, there are 3 PostgreSQL nodes in streaming replication, and node 0 is the primary. If the weight of all the PostgreSQL nodes becomes equal, queries are distributed equally (node0 – node 2 receiving select query by 33.33% each node).

backend_weight0 = 1  
backend_weight1 = 1  
backend_weight2 = 1

If the primary node is dedicated to executing WRITE queries, you can specify the weight of node 1 to 2:

backend_weight0 = 0  
backend_weight1 = 1  
backend_weight2 = 1

If the primary node is used to execute SELECT queries too, you can specify the weight of node 0 to 2:

backend_weight0 = 0,2  
backend_weight1 = 0,4  
backend_weight2 = 0,4

## Load Balancing Mode in Pgpool-II

When load balancing is enabled, every user session to the PostgreSQL server through Pgpool-II uses two or more DB nodes to serve the client requests. One is the primary server (for INSERT/UPDATE/DELETE statements) while the other is _load_balance_node_ which is used for sending the SELECT queries in order to distribute the load.

1.  **Session Level Load Balancing Mode**
    
    By default, the load balance mode is at a **“session level”** which means the node read queries that are sent is determined when a client connects to Pgpool-II. For example, if we have node 0 and node 1, one of the nodes is selected randomly each time a new session is created. In the long term, the possibility of which node is being chosen will be getting closer to the ratio specified by backend_weight0 and backend_weight1. If those two values are equal, then the chance of each node to be chosen will be even.
    
    ![Pgpool II blogImg 3](https://ashnik-images.s3.amazonaws.com/prod/wp-content/uploads/2022/06/15194805/Pgpool-II-blogImg-3.png "Scaling up and load balancing your PostgreSQL Cluster using Pgpool-II 4")
    
2.  **Statement Level Load Balancing Mode**
    
    If statement_level_load_balance is set to “on”, the load balance node is determined at the time each query starts. This is useful in case that application has its own connection pooling which keeps on connecting to Pgpool-II and the load balance node will not be changed once the application starts. Another use case is a batch application. It issues tremendous number of queries but there’s only 1 session. With statement level load balancing mode it can utilize multiple servers.
    
    ![Pgpool II blogImg 4](https://ashnik-images.s3.amazonaws.com/prod/wp-content/uploads/2022/06/15194802/Pgpool-II-blogImg-4.png "Scaling up and load balancing your PostgreSQL Cluster using Pgpool-II 5")
    

## Which is the best mode for your application?

As minimal as it may be, but selecting a load balancing node consumes the CPU cycle and has its own overheads. Selecting the right load balancing mode is important. Some of the considerations for selecting the mode could be:

-   If the cluster has only one primary and one standby, then there is no need to enable statement-level load balancing.
-   If the setup has more than one read replicas and the application has its own connection pooling then the statement-level load balancing is the best choice.
-   If the applications in the setup normally issue a few queries for each session and create a lot of sessions, then the session-level load balancing mode is the right way to go. While for batch processing and long user sessions, statement-level load balancing performs better.

## Best Architecture to deploy Pgpool-II.

Generally, you would not install Pgpool-II on the backend servers. What you see in recent picture is the most common configuration. Pgpool-II is a standalone server which essentially sits in front of the databases. The two Postgres servers are often configured with streaming replication with one being the Primary DB and the other the Standby DB.

![Pgpool II blogImg 5](https://ashnik-images.s3.amazonaws.com/prod/wp-content/uploads/2022/06/15194758/Pgpool-II-blogImg-5.png "Scaling up and load balancing your PostgreSQL Cluster using Pgpool-II 6")

You can also have multiple Pgpool-II servers to achieve better high availability. Technically you could install Pgpool-II on the database servers in this configuration, but this would be bad practice. In order to implement high availability of the entire system, pgpool-II itself also needs to be made redundant. This feature for this redundancy is called Watchdog. Here is how it works:

1.  Watchdog links multiple instances of Pgpool-II in an active/standby setup. Then, the linked Pgpool-II instances perform mutual hearbeat monitoring and share server information (host name, port number, Pgpool-II status, virtual IP information, startup time).
2.  If Pgpool-II (active) providing the service fails, Pgpool-II (standby) autonomously detects it and performs failover. When doing this, the new Pgpool-II (active) starts a virtual IP interface, and the old Pgpool-II (active) stops its virtual IP interface.
3.  This allows the application side to use Pgpool-II with the same IP address even after the switch of the servers. By using Watchdog, all instances of Pgpool-II work together to perform database server monitoring and failover operations – pgpool-II (active) works as the coordinator.

## Pgpool-II Parameter that you should looking out.

Sometimes we ask how to configure Pgpool-II’s number of connection parameter or life cycle parameter that we need to configure regarding our PostgreSQL specification. Note that Pgpool-II may establish **_num_init_children \* max_pool connections_** to each PostgreSQL server. And PostgreSQL allows concurrent connections for non-superusers up to **_max_connections – superuser_reserved_connections_**.

In addition, canceling a query creates another connection to PostgreSQL. Therefore, **_max_pool, num_init_children, max_connections, superuser_reserved_connections_** must satisfy the following formula:

-   **(no query canceling needed)**
    
    max_pool\*num_init_children <= (max_connections - superuser_reserved_connections)
    
-   **(query canceling needed)**
    
    max_pool\*num_init_children\*2 <= (max_connections - superuser_reserved_connections) another parameter that we could configure based on our need and connection is:
    
-   **child_life_time**
    
    This parameter indicates the last client disconnection. The maximum duration to avoid memory leakage caused by not exiting session for a long time. After the client disconnects the database, the subprocess switches request status, if child_life_time configured within specific time range. If no, client will establish a connection with the subprocess, the subprocess will be killed and regenerate new child processes and indicates that child processes will never exit.
    
-   **client_idle_limit**
    
    Specifies the time in seconds to disconnect a client if it remains idle since the last query. This is useful for preventing the Pgpool-II children from being occupied by a lazy clients or broken TCP/IP connection between client and Pgpool-II. If a client is idle after executing the last query, this client’s connection will begin to break off. This parameter can prevent the idle connection of the client from taking up the number of connections for a long time. This paper also uses this parameter to optimize the database. Which means never disconnect.
    
-   **child_max_connections**
    
    This parameter represents Pgpool-II maximum number of connections that allowed, when Pgpool-II established connections reached child_max_connections After the configured number, the oldest subprocess will exit first. This parameter is mainly used in scenarios with large concurrency and can’t be triggered in a short time.
    
-   **connection_life_time**
    
    This parameter represents the maximum time to establish a connection with the back end of the database. It is mainly used for caching to improve the performance of the database.
    
Hope this article helped you get a better understanding on improving the performance of your PostgreSQL cluster by using Pgpool-II features. 

## Reference

* https://www.ashnik.com/scaling-up-and-load-balancing-your-postgresql-cluster-using-pgpool-ii/
* 
