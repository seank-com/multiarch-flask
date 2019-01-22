# multiarch-flask
A multiarch flask container

### Building the container (native and emulated)

To build x86_64 (native)

```bash
$ docker build -t multiarch-demo:x86_64 -f demo/Dockerfile.x86_64 demo/
```

To build arm64 (native)

```bash
$ docker build -t multiarch-demo:arm64 -f demo/Dockerfile.arm64 demo/
```

To build arm (emulated)

```bash
$ docker run --rm --privileged multiarch/qemu-user-static:register --reset
$ docker build -t multiarch-demo:arm64 -f demo/Dockerfile.arm64 demo/
```

### Running the container

To run x86_64 (native)

```bash
$ nvidia-docker run -it --rm multiarch-demo:x86_64
```

To run arm64 (natively on nVidia Jetson TX2)

```bash
$ docker run -it --rm --device=/dev/nvhost-ctrl --device=/dev/nvhost-ctrl-gpu --device=/dev/nvhost-prof-gpu --device=/dev/nvmap --device=/dev/nvhost-gpu --device=/dev/nvhost-as-gpu -v /usr/lib/aarch64-linux-gnu/tegra:/usr/lib/aarch64-linux-gnu/tegra -v /usr/local/cuda-9.0/targets/aarch64-linux/lib:/usr/local/cuda-9.0/targets/aarch64-linux/lib -v /usr/lib/aarch64-linux-gnu:/usr/lib/aarch64-linux-gnu -p 80:80 multiarch-demo:arm64
```

### Additional Info

Moved to [notes](Notes.md) to keep this file simple.