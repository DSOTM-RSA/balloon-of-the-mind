## Working with Docker

### pull a given image
docker pull mcr.microsoft.com/dotnet/core/samples:aspnetapp

### list images stored locally
docker image list

### run in the background on specified port
docker run -d -p 8080:80 mcr.microsoft.com/dotnet/core/samples:aspnetapp

### show containers running in local registry
docker ps

### stop a given container
docker container stop <NAME>

### show all container (including those stopped)
docker ps -a

### remove container 
docker container rm <NAME>

### remove image from registry
docker image rm mcr.microsoft.com/dotnet/core/samples:aspnetapp



