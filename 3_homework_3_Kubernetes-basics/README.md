## Task 4. Solution :man_technologist:
[BASE] Run app https://github.com/den-vasyliev/go-demo-app with helm. Troubleshoot minors. Check readiness by 
```
 wget -O /tmp/g.png https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png
 curl -F 'image=@/tmp/g.png'   APIGW_IP_ADDR/img/
```
[Asciinema](https://asciinema.org/a/418669)

1. Let's get rid off warnings. Simply we need to change rbac.authorization.k8s.io/v1beta1 Role to rbac.authorization.k8s.io/v1 Role
```
vim charts/api-gateway/templates/rbac.yaml
```
2. To get rid off 'manifest_sorter.go:192: info: skipping unknown hook: "crd-install"'  we need to create cdr/ dir in
```
mkdir charts/nats/crds/
mv charts/nats/templates/customresourcedefinition.yaml charts/nats/crds/
```
3. Also, we need to move to crd directory another custom resource definition NatsCluster charts/nats/templates/natscluster.yaml
```
mv charts/nats/templates/natscluster.yaml charts/nats/crds/
```
4. Let's create name space "test"
```
k create ns test
```
5. Let's create template test in namespace test and apply to Kubernetes cluster
```
helm template test ./ --namespace test | k apply -n test -f -
```
6. Check pods, deploys, services
```
k get po -n test
k get deploy -n test
k get svc -n test 
```
7. Let's check readiness
```
wget -O /tmp/g.png https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png
curl -F 'image=@/tmp/g.png'   APIGW_IP_ADDR/img/
```
[BASE] Ставим стек эластика [оператором](https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-deploy-eck.html). [Asciinema](https://asciinema.org/a/418680).

1. Install custom resource definitions and the operator with its RBAC rules
```
k apply -f https://download.elastic.co/downloads/eck/1.6.0/all-in-one.yaml
```
2. Monitor the operator logs
```
k -n elastic-system logs -f statefulset.apps/elastic-operator
```
3. Create 2 kinds: Elasticsearch and Kibana
```
cat <<EOF | kubectl apply -f -
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: quickstart
spec:
  version: 7.13.1
  nodeSets:
  - name: default
    count: 1
    config:
      node.store.allow_mmap: false
EOF
```
```
kubectl get elasticsearch
```
```
cat <<EOF | kubectl apply -f -
apiVersion: kibana.k8s.elastic.co/v1
kind: Kibana
metadata:
  name: quickstart
spec:
  version: 7.13.1
  count: 1
  elasticsearchRef:
    name: quickstart
  http:
    tls:
      selfSignedCertificate:
        disabled: true
EOF
```
```
kubectl get kibana
```
4. Get to Kibana UI on http://localhost:5601
```
PASSWORD=$(kubectl get secret quickstart-es-elastic-user -o go-template='{{.data.elastic | base64decode}}')
```
```
k get svc
k port-forward svc/quickstart-kb-http 5601

username: elastic
password: $PASSWORD
```


## Task 3. Solution :man_technologist:
[BASE] 2 versions of application and canary. [Asciinema](https://asciinema.org/a/418500)
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
curl EXTERNAL-IP:80
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
curl EXTERNAL-IP:80
```
[BASE] using repo creat pod with secrets. [Asciinema](https://asciinema.org/a/418496)
1. Let's encrypt secrets
```
echo -n 'pass_1' | base64
```
Output
```
cGFzc18x
```
```
echo -n '2_pass' | base64
```
Output
```
Ml9wYXNz
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
[BASE] app-multicontainer task. [Asciinema](https://asciinema.org/a/418533)
1. Let's create pod app-two-containers
```
---
apiVersion: v1
kind: Pod
metadata:
  name: app-two-containers
spec:
  volumes:
  - name: html
    emptyDir: {}
  containers:
  - name: 1st
    image: nginx
    volumeMounts:
    - name: html
      mountPath: /usr/share/nginx/html
  - name: 2nd
    image: debian
    volumeMounts:
    - name: html
      mountPath: /html
    command: ["/bin/sh", "-c"]
    args:
      - while true; do
          date >> /html/index.html;
          sleep 1;
        done
```
```
k apply -f ./app-two-containers.yaml
```
2. Get deploys, pods and logs
```
k get po
```
```
k describe po
```
```
k logs POD_NAME -c CONTAINER_NAME
```
3. Get pod label
```
k get po --show-labels
```
4. Create label for pod 
```
k label po app-two-containers app=app-two-containers
```
5. Create NodePort service, nodeport.yaml
```
---
apiVersion: v1
kind: Service
metadata:
  name: app-two-containers-np-service
spec:
  selector:
    app: app-two-containers
  type: NodePort
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```
```
k apply -f ./nodeport.yaml
```
6. Create LoadBalancer service, loadbalancer.yaml
```
---
apiVersion: v1
kind: Service
metadata:
  name: app-two-containers-lb-service
spec:
  selector:
    app: app-two-containers
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
```
```
k apply -f ./loadbalancer.yaml
```
7. Get created services
```
k get svc
```
8. Get nodes, to see IPs and test NodePort service
```
k get nodes
```
9. Create firewall rule to allow TCP traffic to nodes
```
gcloud compute firewall-rules create test-node-port --allow tcp:30000-32768
```
10. Test NodePort service
```
curl NODE_IP:NODEPORT
```
11. Test LoadBalancer
```
curl LoadBalancer_EXTERNAL_IP:80
```
[EXT] app-multicontainer-no-lb-np [Asciinema](https://asciinema.org/a/418563)
1. Check that we do not have helping services, NodePort, LoadBalancer
```
k get svc
```
2. Let's modify app-two-containers.yaml by specifying hostNetwork:false (to use different ports for pod and container), containerPort for nginx image, hostPort and create new pod
```
---
apiVersion: v1
kind: Pod
metadata:
  name: app-two-containers
spec:
  hostNetwork: false
  volumes:
  - name: html
    emptyDir: {}
  containers:
  - name: 1st
    image: nginx
    ports:
      - containerPort: 80
        hostPort: 9090
    volumeMounts:
    - name: html
      mountPath: /usr/share/nginx/html
  - name: 2nd
    image: debian
    volumeMounts:
    - name: html
      mountPath: /html
    command: ["/bin/sh", "-c"]
    args:
      - while true; do
          date >> /html/index.html;
          sleep 1;
        done
```
```
k apply -f app-two-containers.yaml
```
3. Create ingress rule for gcp firewall
```
gcloud compute firewall-rules create test-nodeport --allow tcp:9090
```
4. Test using node IP where pod is located
```
curl NODE_IP:9090
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

NOTES TO TASK 1:
1. asciinema for coding: [Core solution](https://asciinema.org/a/416595) and [Ext solution](https://asciinema.org/a/dZy24YeAycZSu7HTnH5nrmHWd)
2. Online core solution presented on [YouTube](https://youtu.be/1_cRj-NVCSg)
3. Online ext solution presented on [YouTube](https://youtu.be/PAM0Jw4LN2E) 
