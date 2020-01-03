# gke-simple-cluster

Creates a simple zonal GKE cluster with no default node pool, a primary node pool with 2 initial nodes and autoscaling between 1 and 10 nodes.

Also configures gcloud to use account in GOOGLE_APPLICATION_CREDENTIALS, grants the user `cluster-admin`, and configures `kubectl`.

```
$ make apply-gke-simple-cluster
...

$ kubectl get nodes
...

$ make destroy-gke-simple-cluster
...
```
