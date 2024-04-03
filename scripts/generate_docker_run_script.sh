#!/bin/bash

# Ensure container name or ID is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <container_name_or_id>"
    exit 1
fi

container_name_or_id=$1

# Start generating the bash script
echo "#!/bin/bash" > run_container.sh
echo "" >> run_container.sh

# Extract the image name
image=$(docker inspect --format='{{.Config.Image}}' "$container_name_or_id")

# Add the docqqker run command with the image name
echo "docker run --name csullivan-devc-$container_name_or_id --entrypoint=/bin/bash -it \\" >> run_container.sh

# Extract and format environment variables
docker inspect --format='{{range .Config.Env}}{{printf "-e %q \\" .}}{{end}}' "$container_name_or_id" >> run_container.sh

# Append the image name to the run command
echo "$image " >> run_container.sh


# Final touches and instructions
echo "Generated run_container.sh successfully."

# Make the generated script executable
chmod +x run_container.sh

echo "Run './run_container.sh' to start the container with the image $image."

