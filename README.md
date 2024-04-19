### Auto-Deploy Script for React Application

[Video Demo](assets/vid.mkv)

This script automates the deployment process of a Node.js application by monitoring a Git repository for changes and rebuilding the app when new commits are detected.

### Prerequisites

- Git
- Node.js with npm
- inotify-tools (for Linux systems)

### Local Usage

1. Run the script with the repository URL as the first argument: `./monitor.sh <repo_url>`
2. Enter the time period (in seconds) for detecting changes.

The script will clone or update the repository, install dependencies, build the application, and serve it at <http://localhost:3000>. Whenever changes are detected in the repository, the script will pull the latest commits, rebuild the app, and restart the server.

### Error Handling

The script includes error handling for the following scenarios:

- Missing repository URL
- Failed repository cloning or updating
- Failed dependency installation
- Failed build process

In case of an error, the script will display an error message and either exit or continue monitoring, depending on the error.

### File Watcher

The script uses `inotifywait` to monitor the repository for changes. It watches for file modifications, moves, creations, and deletions, and triggers a rebuild when any of these events occur.

### Serving the Application

The script serves the application using the `serve` package. The server process runs in the background, allowing the script to continue monitoring for changes. When a new build is triggered, the script kills the existing server process and starts a new one.

### Build docker image

```
docker build -t react-app:1.0 .
```

### Run the container

```
docker run --rm -it -p 3000:3000 react-app:1.0 /bin/bash monitor.sh https://github.com/thebigbone/create-react.git
```
