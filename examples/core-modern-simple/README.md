# core-modern-simple

* Create a zonal GKE cluster with 1 node pool
* Install tiller
* Helm release stable/nginx-ingress
* Grab ingress IP for CloudBees Core config
* Helm release cloudbees/cloudbees-core

```
$ make apply-core-modern-simple
...
null_resource.echo_url (local-exec): Executing: ["/bin/sh" "-c" "echo http://35.225.1.66.beesdns.com/cjoc"]
null_resource.echo_url (local-exec): http://35.225.1.66.beesdns.com/cjoc
null_resource.echo_url: Creation complete after 0s [id=1986130056910831576]

$ kubectl exec cjoc-0 -n cloudbees-core -it cat /var/jenkins_home/secrets/initialAdminPassword
...

$ make destroy-core-modern-simple
....
```
