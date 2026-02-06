Setting up your environment
=======
We will be using Docker again in our development process. Given that this is your second time doing so, we are 
providing streamlined directions to get started and to test the running application in the Docker container that you
build.

1. Given the [Dockerfile](Dockerfile) we provide in the repo, build the Docker image with the following command:
```bash
docker build -t hw-sinatra-saas-wordguesser:latest .
```
2. Run the container as follows.  Note that once you execute this command, you should be presented with a bash shell
prompt that is running __inside__ the running container.  That is, it's a shell in the container, not on your host
operating system.
```bash
docker run -p 3000:3000 -v "$(pwd)":/app -it hw-sinatra-saas-wordguesser
```

The `-p` option sets the configuration where communications traffic will pass from the host operating system into the 
container at the specified port. The first number (before the colon) is the host port — the port on your local machine 
that will accept incoming traffic. The second number (after the colon) is the container port — the port inside the 
container where the application is listening. We also use the `-v` option is used to mount the specified part of your 
host operating system into the container. This means that changes to files inside the container will be visible 
outside the container, and vice versa. One limitation with our current configuration is that the container does not 
really have many good file editing tools installed. We could change that, but for now, file changes should occur 
outside the container with your favorite editor. Finally, the `-it` option to the `docker run` command is really a 
combination of two options (`-i` and `-t`) which essentially provide us with the interactive terminal once the 
container is running.

3. Now, install the required gems. Remember to execute this in the running shell __inside__ of the container.
```bash
bundle install
```

4. Once the gems are installed, we can start the `rackup` server on port 3000 (the `-p 3000` option) and binding to the 
specified host address (`--host 0.0.0.0)`.  The server is started in the __background__ so that we can issue more commands
in the shell. Without the `&` symbol, the server will run, but block further interactions with the shell until we 
terminate the server.
```bash
bundle exec rackup --host 0.0.0.0 -p 3000 &
```
5. Let's test the setup!  On your host machine open a web browser and go to `http://localhost:3000`. You should see the 
running application 

-----

Next: [Part 0: Demystifying SaaS app creation](docs/part_0_create_saas_app.md)