docker build -t multiarch-uwsgi-nginx:x86_64 -f uwsgi-nginx/Dockerfile.x86_64 uwsgi-nginx/
docker build -t multiarch-uwsgi-nginx-flask:x86_64 -f uwsgi-nginx-flask/Dockerfile.x86_64 uwsgi-nginx-flask/
docker build -t multiarch-demo:x86_64 -f demo/Dockerfile.x86_64 demo/

docker build -t multiarch-uwsgi-nginx:aarch64 -f uwsgi-nginx/Dockerfile.aarch64 uwsgi-nginx/
docker build -t multiarch-uwsgi-nginx-flask:aarch64 -f uwsgi-nginx-flask/Dockerfile.aarch64 uwsgi-nginx-flask/
docker build -t multiarch-demo:aarch64 -f demo/Dockerfile.aarch64 demo/
