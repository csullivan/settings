docker build -t csullivan-dev .
docker tag csullivan-dev:latest gitlab-master.nvidia.com:5005/chrsullivan/dev
docker push gitlab-master.nvidia.com:5005/chrsullivan/dev
