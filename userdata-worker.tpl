#!/bin/bash
sudo yum update –y
sudo yum install nfs-utils -y
sudo mount -t nfs -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport "${aws_efs_mount_target.jenkins-efs-mount-target.ip_address}":/   ~/efs-mount-point 
