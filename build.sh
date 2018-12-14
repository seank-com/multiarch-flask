docker build -t multiarch-demo:x86_64 -f demo/Dockerfile.x86_64 demo/

docker build -t multiarch-demo:aarch64 -f demo/Dockerfile.aarch64 demo/


# docker run -d --rm -p 80:80 multiarch-demo:x86_64 /bin/sh
