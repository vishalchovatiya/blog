## Useful links
- Framework for blogging: https://gohugo.io/
- Theme: https://github.com/luizdepra/hugo-coder
    - Blog sample live: https://hugo-coder.netlify.app/
    - Blog sample github repo: https://github.com/luizdepra/hugo-coder/tree/main/exampleSite

## Working with Docker & VSCode
- Note: all these instructions are for windows & tested for windows

1. Clone this repo
2. Open the command prompt from repo directory and build the image
    ```
    docker build -t blog .
    ```
3. Run the container from repository directory terminal(dont use powershell)
    ```
    docker run -d -p 2222:22 --security-opt seccomp:unconfined -v %cd%:/blog --name blog blog
    ```
    - The -d parameter detaches the Docker container from the terminal. The -p parameter links the port 2222 to the exposed 22 port of the container. As debugging requires running privileged operations, you'll run the container in unconfined mode, thus the --security-opt set to seccomp:unconfined. The -v parameter creates a bind mount that maps the local file system (%cd% - print working directory) into the container (/blog). Therefore, you need to be inside the source code folder while you run this command, or you can change the $PWD value with a full path to the source directory.
4. Open VSCode and attach to running container `blog`
5. Open the folder `blog` from root 
6. Go to `/blog/vishalchovatiya` and run `hugo server` to build the site

Misc: Start existing container either from terminal with below command or by clicking on start button in docker desktop
```
docker start -i blog
```
