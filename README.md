# UFS App Containerization: Docker and Singularity

This repository provides the collections of Docker and Singularity build recipes that can be applied for the ufs srw and mrw applications. hpc-stack and ufs-srw Docker container images are built in the git workflow and pushed to the Docker Hub. Available Docker containers include:

* docker://noaaepic/ubuntu20.04-gnu9.3

* docker://noaaepic/ubuntu20.04-gnu9.3-hpc-stack

* docker://noaaepic/ubuntu20.04-gnu9.3-ufs-srwapp

* docker://noaaepic/ubuntu20.04-gnu9.3-ufs-mrwapp

Dockerfile tree:

```
Docker/
└── gnu9.3
    ├── Dockerfile
    ├── hpc-stack
    │   └── Dockerfile
    └── ufs-srwapp
        └── Dockefile
```