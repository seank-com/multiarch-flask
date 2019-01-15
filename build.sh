#docker build -t multiarch-demo:x86_64 -f demo/Dockerfile.x86_64 demo
#docker build -t multiarch-demo:arm64 -f demo/Dockerfile.arm64 demo/

#docker run --rm --privileged multiarch/qemu-user-static:register --reset
docker build -t multiarch-bld -f bld/Dockerfile.multi bld/

# docker run -d --rm -p 80:80 multiarch-demo:x86_64 /bin/sh
