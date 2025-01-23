# Redis Enterprise Grafana Dashboards

This repository contains a collection of Grafana dashboards for [Redis Enterprise](https://docs.redis.com/latest/rs/) and [Redis 
Cloud](https://docs.redis.com/latest/rc/).
These dashboards rely on metrics exported by the Redis Enterprise and Redis Cloud Prometheus endpoints.

The dashboards are separated according Grafana version; older versions used a plugin from Angular which more recent versions do not. 

* For dashboards intended for use with versions 7-9 of Grafana, see [v7-9](dashboards/grafana_v7-9/README_v7-9.md)
* For dashboards intended for use with versions 9-11 of Grafana, see [v9-11](dashboards/grafana_v9-11/README_v9-11.md)

## Running
Run the setup script to bring up Redis Enterprise, prometheus, and grafana using docker compose and initialize the Redis Enterprise cluster.

```
cd ./demo
./setup.sh
```

That will take 1-2 mins to run and you might see retries as it attempts to configure Redis Enterprise. It will print out the various URLs you can open in your local browser when its finished running.

## Running a second (or third) instance of this setup
If you need to run more than one standalone instance of this RE/Prometheus/Grafana setup you can do so and it will bind to non standard ports on your host os.

Provide a name like this:

```
./setup.sh secondsetup

# see all the compose projects running
docker compose ls

# shut it down
docker compose -p secondsetup down
```