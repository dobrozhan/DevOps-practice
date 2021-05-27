## Task :man_technologist:

[BASE]

1. Закрепить материал на практике
2. Докинуть нетворк в ваш контейнер, поднятый runc (внести изменения в config.json - можно воспользоваться https://medium.com/@Mark.io/https-medium-com-mark-io-network-setup-with-runc-containers-46b5a9cc4c5b)
3. Сбилдать свой имедж и запушить в режестри

[EXT]

4. Поднять кубер любым способом и запустить свой имедж как деплоймент

## Solution :monocle_face:

[BASE]
1. Create aliases

`alias d=docker`

`alias k=kubectl`

2. Create dir demo and cd to it

`mkdir demo`

`cd demo`

3. Pull image busybox from Docker Hub registry

`d pull busybox`

4. Display docker images on host

`d images`

5. Create root dir for image

`mkdir rootfs`

6. Run image in container

`d run busybox`

7. See containers

`d ps -a`

8. Export container, extract it to rootfs dir

`d export CONTAINER_ID | tar xf - -C rootfs/`

9. Initialize config.json

`run spec`

10. Switch to root bash

`sudo bash`

11. Run demo image using runc

`runc run demo`

12. Display network interfaces in demo image

`ip a`

13. Exit from image

`exit`

14. Edit config.json to add demo_network namespace

`vim config.json`

`"path": "/var/run/netns/demo_network"`

15. See available net namespaces

`sudo ip netns ls`

16. Create new net namespace demo_network

`sudo ip netns add demo_network`

17. Create to virtual interfaces to have a bridge between host and container

`sudo ip link add name veth-host type veth peer name veth-demo`

18. Check available interfaces

`sudo ip link ls`

19. Set veth-demo interface to net namespace demo_network

`sudo ip link set veth-demo netns demo_network`

20. Check applied changes to interfaces (you will not see veth-demo, it is in demo_network namespace)

`sudo ip link ls`

21. See interfaces in net namespace demo_network

`sudo ip -netns demo_network link ls`

22. Configure CIDR for veth-demo interface

`sudo ip netns exec demo_network id addr add 192.168.10.1/24 dev veth-demo`

23. Up veth-demo interface

`sudo ip netns exec demo_network ip link set veth-demo up`

24. Up loopback interface

`sudo ip netns exec demo_network ip link set lo up`

25. Check applied changes

`sudo ip -netns demo_network addr`

26. Up veth-host interface

`sudo ip link set veth-host up`

26. Add route to veth-host to have a route connection with veth-demo

`sudo ip route add 192.168.10.1/32 dev veth-host`

27. Check applied changes

`sudo ip route`

28. Add route for veth-demo

`sudo ip netns exec demo_network ip route add default via 192.168.10.1 dev veth-demo`

29. Check if we have connection between veth-host and veth-demo

`ping 192.168.10.1`

30. Change shell to root bash

`sudo bash`

31. Run demo images using runc

`runc run demo`

32. Check new network configuration

`ip a`

33. Exit from image

`exit`

34. Create dockerfile with name containerfile and directives FROM, CMD, EXPOSE

`vim containerfile`

`FROM busybox`

`CMD while true; do { echo -e "HTTP/1.1 200 OK\r\n"; } | ns -vlp 8000; done`

`EXPOSE 8000`

35. Build docker image using containerfile

`docker build -f containerfile .`

36. Check available docker images

`d images`

37. Add tag and repository to docker image

`d tag IMAGE_ID gcr.io/basecamp-globallogic-21/demo:v1.0.0`

38. Push image to Google container registry

`d push gcr.io/basecamp-globallogic-21/demo:v1.0.0`

[EXT]

1. Create GCP instance and ssh to it (GCP console)

2. Fetch and install k3s

`curl -sfL https://get.k3s.io | sh -`

3. Set alias

`alias k=kubectl`

4. Configure k3s

`export KUBECONFIG=/etc/rancher/k3s/k3s.yaml`

5. Step to root bash

`sudo bash`

6. Change permission for all to read /etc/rancher/k3s/k3s.yaml and exit root bash

`chmod a+r /etc/rancher/k3s/k3s.yaml`

`exit`

7. Inspect k3s installation

`k get all -A`

8. Create deployment from image demo on gcr.io

`k create deploy --image=gcr.io/basecamp-globallogic-21/demo:v1.0.0`

9. See deploy details

`k describe deploy`

10. Check pods

`k get po`

11. See pod details

`k describe po`


NOTES
1. ascinema for coding presented on
2. Core solution presented on [YouTube](https://youtu.be/1_cRj-NVCSg)
3. Solution for addition task presented on [YouTube](https://youtu.be/PAM0Jw4LN2E) 
