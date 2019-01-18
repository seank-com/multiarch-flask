# multiarch-flask
A multiarch flask container

## Install Steps for IoT Edge on NVIDIA Jetson Tx2
### Multi-architecture method

**Prerequisites:** This assumes you already have docker up and running. You can also use Moby by following the instructions at https://docs.microsoft.com/en-us/azure/iot-edge/how-to-install-iot-edge-linux-arm just before the installation of IoT Edge in step: 10

```bash
# enable installation of 32 bit packages
sudo dpkg --add-architecture armhf

# install compilers and libraries
sudo apt-get install libc-bin libc-bin libc-dev-bin libc6 libc6:armhf libc6-dev libgcc1 libgcc1:armhf locales

wget http://ports.ubuntu.com/ubuntu-ports/pool/main/h/hostname/hostname_3.16ubuntu2_armhf.deb

sudo dpkg -i ./hostname_3.16ubuntu2_armhf.deb

wget http://ftp.us.debian.org/debian/pool/main/o/openssl1.0/libssl1.0.2_1.0.2l-2+deb9u3_armhf.deb
sudo dpkg -i libssl1.0.2_1.0.2l-2+deb9u3_armhf.deb
sudo apt-get install -f

# If you get any error message, it may be related to the fact you have a non-compatible 
# version of libssl like the libsll-dev version. In this case, just purge it with  
# sudo apt-get purge libssl-dev

wget https://aka.ms/libiothsm-std-linux-armhf-latest -O libiothsm-std.deb
sudo dpkg -i ./libiothsm-std.deb
wget https://aka.ms/iotedged-linux-armhf-latest -O iotedge.deb
sudo dpkg -i ./iotedge.deb
sudo apt-get install -f

# Add the connection string to your Edge device as usual (or configure dps)  
# Change the edgeAgent config/image to reflect the architecture.
# For example "mcr.microsoft.com/azureiotedge-agent:1.0.0-linux-arm32v7" 

sudo nano /etc/iotedge/config.yaml

# Add the line below (without the leading #) in the In the [Service] section  
# Environment=LISTEN_FDNAMES=iotedge.mgmt.socket:iotedge.socket

sudo nano /etc/systemd/system/multi-user.target.wants/iotedge.service

sudo systemctl restart iotedge
```

### Building containers

Just run the following:

```bash
$ ./build.sh
```

### Running the container

```bash
$ docker run -d --rm -p 80:80 multiarch-demo:x86_64
```

### Notes for Building TensorFlow

Lukasz Janyst has steps from [cross-compiling TensorFlow for Jetson](https://jany.st/post/2018-02-05-cross-compiling-tensorflow-for-jetson-tx1-with-bazel.html) that we found in this Github [issue](https://github.com/tensorflow/tensorflow/issues/16779), we want to build natively, but perhaps we can use some of his learnings.

Zhiyi has some nice steps for [compiling Tensorflow natively for Arm64](http://zhiyisun.github.io/2017/02/15/Running-Google-Machine-Learning-Library-Tensorflow-On-ARM-64-bit-Platform.html) that we will probably need to make use of.

Steps for [building TensorFlow from source](https://www.tensorflow.org/install/source)

Steps for [building Bazel from source](https://docs.bazel.build/versions/master/install-compile-source.html)


```bash
$ ./configure
$ bazel build --config=opt --define=grpc_no_ares=true //tensorflow/tools/pip_package:build_pip_package
```

### Troubleshooting:

* If you run edge as a daemon, you may end up getting 127 errors.  This just says something went wrong in the process started by the system.  If you want better error info, you can try running iotedged from the command line using: 

```bash
sudo systemctl stop iotedge
sudo /usr/bin/iotedged -c /etc/iotedge/config.yaml
```

* **Note**, if you run iotedged from the command line, and it configures hsm, you will need to clear that configuration before starting iotedged as a service.  If not, the service will fail repeatedly at the configuring hsm stage.  You can clear it by removing the libiothsm, and deleting the /var/lib/iotedge/hsm directory.  Then reinstall libiothsm as before.  

More info about the libssl install and adding LISTEN_FDNAMES environment variable is available [here](https://blogs.msdn.microsoft.com/laurelle/2018/08/17/azure-iot-edge-support-for-raspbian-8-0-debian-8-0/).
