# Build Flask (native and emulated)

#docker build -t multiarch-demo:x86_64 -f demo/Dockerfile.x86_64 demo/
docker build -t multiarch-demo:arm64 -f demo/Dockerfile.arm64 demo/
#docker tag multiarch-demo:arm64 seankelly/multiarch-demo:arm64-latest