# Build Bazel (native) - [does not build emulated](https://github.com/bazelbuild/bazel/issues/7135)

docker build -t multiarch-bazel -f bld/Dockerfile.bld-bazel bld/
docker tag multiarch-bazel seankelly/multiarch-bazel:arm64-latest
#docker push seankelly/multiarch-bazel:arm64-latest

# Build TensorFlow (emulated)

#docker run --rm --privileged multiarch/qemu-user-static:register --reset
docker container create --name extract multiarch-bazel
docker container cp extract:/root/bazel-0.21.0/output/bazel ./bazel
docker container rm -f extract

docker build -t multiarch-bld -f bld/Dockerfile.bld-tf bld/

# Build Flask (native and emulated)

#docker build -t multiarch-demo:x86_64 -f demo/Dockerfile.x86_64 demo/
#docker build -t multiarch-demo:arm64 -f demo/Dockerfile.arm64 demo/

