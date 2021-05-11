# Auto-HA-Kube-Cluster

In this project, What I was trying to do was to automate the creation of a highly available Kubernetes Cluster on AWS. The key part of this work was not using any external load balancer for the highly available cluster. The Keepalived and Haproxy were my tools to costruct this infrastructure. 

1. Create the Infrastructure for an HA Kubernetes Cluster with Terraform
    |__ This was the easy part...

2. Provision highly available LoadBalancers with Virtiual IP
    |__ Unfortunately AWS doesn't support that. AWS doesn't support the protocol (VRRP - Virtual Routing Redundency Protocol) behind the Virtual IP technology. If it were so, there wouldn't be any need for a load balancer in a Highly Available Kubernetes Cluster. We would use the control plane instances as our load balancers. But there is a [work around](https://serverfault.com/questions/436039/is-it-not-possible-to-use-keepalived-in-ec2#:~:text=Keepalived%20%26%20VRRP%20works%20within%20an,conf%20), you can use Elastic IP and the API of the AWS to attach and detach that specific elastic IP. 

3. Initialize the cluster and Add the control plane instances
    |__ The cluster is initialized on the first master node with a virtual ip. But the rest is that the other instances can not find a way to bind to that first master node. If you set the first instance's real private ip as a virtual ip then you get the cluster and sometimes you get the other control plane instances. Once something weird happened. I first set a virtual ip unused in the same subnet as a virtual ip. Then I reset the first node's real ip as the virtual ip. I canceled all checks in the haproxy config file. After that two extra instances were added to the cluster as other control plane instances. But the cluster was not stabilezed for quite some time and at the end the first control plane node was not able to reach api-server but the other instances worked flawlessly.

4. Add the worker nodes
    |__ ?