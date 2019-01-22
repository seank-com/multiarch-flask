### Installing Cuda libraries natively on the nVidia Jetson TX2

You need to download [JetPack 3.3](https://developer.nvidia.com/embedded/downloads) to your host PC. When you do, you will find ```cuda-repo-l4t-9-0-local_9.0.252-1_arm64.deb``` and ```libcudnn7_7.1.5.14-1+cuda9.0_arm64.deb``` in the ```jetpack_download``` folder. After flashing the device download these two files

Install Process

```bash
$ sudo su -
$ dpkg -i cuda-repo-l4t-9-0-local_9.0.252-1_arm64.deb   
$ apt-key add /var/cuda-repo-9-0-local/7fa2af80.pub   
$ apt-get update   
$ apt-get install cuda-toolkit-9-0 -y 
$ dpkg -i cuda-repo-l4t-9-0-local_9.0.252-1_arm64.deb
```

### Install TensorFlow natively on the nVidia Jetson TX2

```bash
sudo apt-get update
sudo apt-get install python3-dev
wget https://bootstrap.pypa.io/get-pip.py
sudo -H python get-pip.py
sudo -H pip install --extra-index-url https://developer.download.nvidia.com/compute/redist/jp33 tensorflow-gpu
```

### Notes for trying to Build TensorFlow

We started finding Lukasz Janyst steps for [cross-compiling TensorFlow for Jetson](https://jany.st/post/2018-02-05-cross-compiling-tensorflow-for-jetson-tx1-with-bazel.html) that we found in this Github [issue](https://github.com/tensorflow/tensorflow/issues/16779), we want to build natively, but perhaps we could use some of his learnings. Zhiyi has some nice steps for [compiling Tensorflow natively for Arm64](http://zhiyisun.github.io/2017/02/15/Running-Google-Machine-Learning-Library-Tensorflow-On-ARM-64-bit-Platform.html) that we will probably need to make use of. Brainiarc7 [likewise](https://gist.github.com/Brainiarc7/6d6c3f23ea057775b72c52817759b25c). 

To build tensorflow, you must first build bazel. Unfortunately these two projects are tangled in a fatal embrace. As features are added to bazel, they break tensorflow so you have to match specific versions. We started building Bazel 0.21.0 only to learn the Bazel 0.19.1 was the latest version that worked with TensorFlow 1.12.0.

Follow the steps for [building Bazel from source](https://docs.bazel.build/versions/master/install-compile-source.html). Note, you need to build on the native architecture as a bug in qemu doesn't allow bazel to run once it is built, further the script for building bazel tries to build bazel using bazel which is where it fails in emulated environments.

Next follow the steps for [building TensorFlow from source].(https://www.tensorflow.org/install/source). This cannot completely be done in ```docker build``` as you will need to run an interactive configuration script before invoking bazel to build.

```bash
$ ./configure
$ bazel build --config=opt --define=grpc_no_ares=true --sandbox_debug --verbose_failures //tensorflow/tools/pip_package:build_pip_package
```

The parameters above were learned after many hours of trial and failure. But even getting this far we are still seeing linking bugs with unresolved external references. Ideally you would remove ```--sandbox_debug --verbose_failures``` but they are needed until everything compiles and building always restarts from the beginning and takes several hours.

This is just to build the cpu only tensorflow. After that we still need to build with [GPU support](https://www.tensorflow.org/install/gpu).

### Other trails

At this point we came across a [whl](https://devtalk.nvidia.com/default/topic/1031300/jetson-tx2/tensorflow-1-7-wheel-with-jetpack-3-2-/post/5246603/#5246603) from nVidia! The whl requires Python 3.5 which you are supposed to be able to install with the following command

```bash
$ apt-get update -y
$ apt-get install -y software-properties-common
$ add-apt-repository ppa:deadsnakes/ppa
```

Unfortunately, installing ```software-properties-common``` install Python 2.7 and Python 3.6 so you end up with 3 versions in your container.

You could try building Python 3.5 from source

```bash
$ apt-get update
$ apt-get install -y libssl-dev openssl wget make build-essential zlib1g-dev libbz2-dev libsqlite3-dev
$ wget https://www.python.org/ftp/python/3.5.4/Python-3.5.4.tgz
$ tar xzvf Python-3.5.4.tgz
$ cd Python-3.5.4
$ ./configure --with-ensurepip=upgrade
$ make
$ make install
```

But then you are fighting library versions because the repository managers, both apt and pip want to install the latest versions of everything.

Instead of building Python, you could try to install ```virtualenv``` to build a workspace to target Python 3.5

```bash
$ pip install virtualenv
$ virtualenv -p /usr/bin/python3.5 myenv
$ source myenv/bin.activate
```

Unfortunately that last line becomes a stickler in docker because docker builds using ```sh``` and not ```bash```, even if you work around it the environment does not persist from step to step in the Dockerfile.


This is were we decided to wait until someone else with more time and interest would solve the problem for us.

 ### The Final Solution Explained
 
 Ultimately, what worked was to use a xenial based docker container and fix the sources.list to match what is on nVidia Jetson Tx3 when JetPack3.3 is installed. Then ```apt-get``` would work the same way it does on the Jetson. Next add the paths to the cuda libraries to the ```LD_LIBRARY_PATH```. Finally update the volume mappings in the ```docker run``` command to include those locations. *This last step reduced the container size from 3.5GB to 1GB*

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

### Troubleshooting IoT Edge

* If you run edge as a daemon, you may end up getting 127 errors.  This just says something went wrong in the process started by the system.  If you want better error info, you can try running iotedged from the command line using: 

```bash
sudo systemctl stop iotedge
sudo /usr/bin/iotedged -c /etc/iotedge/config.yaml
```

* **Note**, if you run iotedged from the command line, and it configures hsm, you will need to clear that configuration before starting iotedged as a service.  If not, the service will fail repeatedly at the configuring hsm stage.  You can clear it by removing the libiothsm, and deleting the /var/lib/iotedge/hsm directory.  Then reinstall libiothsm as before.  

More info about the libssl install and adding LISTEN_FDNAMES environment variable is available [here](https://blogs.msdn.microsoft.com/laurelle/2018/08/17/azure-iot-edge-support-for-raspbian-8-0-debian-8-0/).
