## Task 3. Solution :man_technologist:
[BASE] 2 versions of application and canary
1. Probe cluster info
```
$ k version
```
```
$ k cluster-info
```
2. Create 2 versions of application and push it to gcr repository
```
$ docker build . -f containerfile_a1 -t gcr.io/gl-bc-spring-21/demo:1.0.0
```
```
containerfile_a1

FROM busybox
CMD while true; do { echo -e "HTTP/1.1 200 OK\n\nVersion:1.0.0";  } | nc -vlp 8000; done
EXPOSE 8000
```
```
$ docker build . -f containerfile_a2 -t gcr.io/gl-bc-spring-21/demo:2.0.0
```
```
containerfile_a2

FROM busybox
CMD while true; do { echo -e "HTTP/1.1 200 OK\n\nVersion:2.0.0";  } | nc -vlp 8000; done
EXPOSE 8000
```
```
d push gcr.io/gl-bc-spring-21/demo:1.0.0
```
```
d push gcr.io/gl-bc-spring-21/demo:2.0.0
```
3. Create deploy using 2 previously created images
```
k create deploy demo-1 --image=gcr.io/gl-bc-spring-21/demo:1.0.0
```
```
k create deploy demo-2 --image=gcr.io/gl-bc-spring-21/demo:2.0.0
```
4. Get deploys, pods and logs
```
k get deploy
```
```
k get po
```
```
k logs POD_NAME
```
5. Create service LoadBalancer for demo deployment
```
k expose deploy demo-1 --type LoadBalancer --port 80 --target-port 8000
```
6. Get services
```
k get svc
```
7. Check if connection has been established
```
curl 35.226.6.88:80
```
8. Get pod's labels
```
k get po --show-labels
```
9. Set new image for pod (concrete container) and annotate that it has been happened
```
k set image deploy demo-1 demo=gcr.io/gl-bc-spring-21/demo:2.0.0 --record
```
10. Check if we changed version of app
```
curl 35.226.6.88:80
```
11. Check history deploy demo
```
k rollout history deploy demo-1
```
12. Return to revision 2
```
k rollout undo deploy demo-1 --to-revision 8
```
13. Scale deploy demo-1 to 9 replicas
```
k scale deploy demo-1 --replicas 9
```
14. Add labels to deploy demo-1 and demo-2
```
k label po --all run=demo
```
15. Add new label run=demo to service demo-1
```
k edit svc demo-1
```
16. In such scenario, only 1/10 request will come to demo-2, and 9/10 to - demo-1
```
curl 35.226.6.88:80
```
[BASE] using repo creat pod with secrets
1. Let's encrypt secrets
```
echo -n 'pass_1' | base64
```
Output
```
cGFzc18x
```
2. Let's create secret using declarative style from secret.yaml
```
---
apiVersion: v1
kind: Secret
metadata:
  name: mysecret1
type: Opaque
data:
  username: cGFzc18x
  password: Ml9wYXNz
```
```
k apply -f ./secret.yaml
```
3. Let's get created secret
```
k get secret mysecret -o wide
```
4. Let's create pod app-secret-env with 2 envs: SECRET_USERNAME, SECRET_PASSWORD applying mysecret1
```
---
apiVersion: v1
kind: Pod
metadata:
  name: app-secret-env
spec:
  containers:
  - name: mycontainer
    image: redis
    env:
      - name: SECRET_USERNAME
        valueFrom:
          secretKeyRef:
            name: mysecret1
            key: username
      - name: SECRET_PASSWORD
        valueFrom:
          secretKeyRef:
            name: mysecret1
            key: password
  restartPolicy: Never
```
```
k apply -f ./app-secret-env.yaml
```
5. Let's get created pod
```
k get pod app-secret-env
```

## Task 2. Solution :man_technologist:
[BASE] asciinema for kubernetes hardway: [1-8 steps](https://asciinema.org/a/417535), [9-14 steps](https://asciinema.org/a/417538)

[EXT] asciinema for practice with IPVS [Ext solution](https://asciinema.org/a/417539)

[OVER] solution for game of PODs (Bravo, Pento, Redis Islands, Tyro) [Based on tutorial provided by Kode Kloud](https://github.com/dobrozhan/GLBaseCamp2021/blob/main/3_homework_3_Kubernetes-basics/gameOfPods)


## Task 1. Solution :man_technologist:
[BASE]
1. Create alias
```
$ alias d=docker
```
2. Create dir demo and cd to it
```
$ mkdir demo
```
```
$ cd demo
```
3. Pull image busybox from Docker Hub registry
```
$ d pull busybox
```
4. Display docker images on host
```
$ d images
```
5. Create root dir for image
```
$ mkdir rootfs
```
6. Run image in container
```
$ d run busybox
```
7. See containers
```
$ d ps -a
```
8. Export container, extract it to rootfs dir
```
$ d export CONTAINER_ID | tar xf - -C rootfs/
```
9. Initialize config.json
```
$ runc spec
```
10. Switch to root bash
```
$ sudo bash
```
11. Run demo image using runc
```
# runc run demo
```
12. Display network interfaces in demo image
```
# ip a
```
13. Exit from image
```
# exit
```
14. Edit config.json to add demo_network namespace
```
$ vim config.json
```
```
"path": "/var/run/netns/demo_network"
```
15. See available net namespaces
```
$ sudo ip netns ls
```
16. Create new net namespace demo_network
```
$ sudo ip netns add demo_network
```
17. Create to virtual interfaces to have a bridge between host and container
```
$ sudo ip link add name veth-host type veth peer name veth-demo
```
18. Check available interfaces
```
$ sudo ip link ls
```
19. Set veth-demo interface to net namespace demo_network
```
$ sudo ip link set veth-demo netns demo_network
``` 
20. Check applied changes to interfaces (you will not see veth-demo, it is in demo_network namespace)
```
$ sudo ip link ls
```
21. See interfaces in net namespace demo_network
```
$ sudo ip -netns demo_network link ls
```
22. Configure CIDR for veth-demo interface
```
$ sudo ip netns exec demo_network ip addr add 192.168.10.1/24 dev veth-demo
```
23. Up veth-demo interface
```
$ sudo ip netns exec demo_network ip link set veth-demo up
```
24. Up loopback interface
```
$ sudo ip netns exec demo_network ip link set lo up
```
25. Check applied changes
```
$ sudo ip -netns demo_network addr
```
26. Up veth-host interface
```
$ sudo ip link set veth-host up
```
26. Add route to veth-host to have a route connection with veth-demo
```
$ sudo ip route add 192.168.10.1/32 dev veth-host
```
27. Check applied changes
```
$ sudo ip route
```
28. Add route for veth-demo
```
$ sudo ip netns exec demo_network ip route add default via 192.168.10.1 dev veth-demo
```
29. Check if we have connection between veth-host and veth-demo
```
$ ping 192.168.10.1
```
30. Change shell to root bash
```
$ sudo bash
```
31. Run demo images using runc
```
# runc run demo
```
32. Check new network configuration
```
# ip a
```
33. Exit from image
```
# exit
```
34. Create dockerfile with name containerfile and directives FROM, CMD, EXPOSE
```
$ vim containerfile
```
```
FROM busybox
CMD while true; do { echo -e "HTTP/1.1 200 OK\r\n"; } | ns -vlp 8000; done
EXPOSE 8000
```
35. Build docker image using containerfile
```
$ d build -f containerfile .
```
36. Check available docker images
```
$ d images
```
37. Add tag and repository to docker image
```
$ d tag IMAGE_ID gcr.io/basecamp-globallogic-21/demo:v1.0.0
```
38. Push image to Google container registry
```
$ d push gcr.io/basecamp-globallogic-21/demo:v1.0.0
```
---
[EXT]

1. Create GCP instance and ssh to it (GCP console)

2. Fetch and install k3s
```
$ curl -sfL https://get.k3s.io | sh -
```
3. Set alias
```
$ alias k=kubectl
```
4. Configure k3s
```
$ export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```
5. Step to root bash
```
$ sudo bash
```
6. Change permission for all to read /etc/rancher/k3s/k3s.yaml and exit root bash
```
# chmod a+r /etc/rancher/k3s/k3s.yaml
# exit
```
7. Inspect k3s installation
```
$ k get all -A
```
8. Create deployment from image demo on gcr.io
```
$ k create deploy demo --image=gcr.io/basecamp-globallogic-21/demo:v1.0.0
```
9. See deploy details
```
$ k describe deploy
```
10. Check pods
```
$ k get po
```
11. See pod details
```
$ k describe po
```
---
NOTES TO TASK 1:
1. asciinema for coding: [Core solution](https://asciinema.org/a/416595) and [Ext solution](https://asciinema.org/a/dZy24YeAycZSu7HTnH5nrmHWd)
2. Online core solution presented on [YouTube](https://youtu.be/1_cRj-NVCSg)
3. Online ext solution presented on [YouTube](https://youtu.be/PAM0Jw4LN2E) 
