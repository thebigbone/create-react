#!/bin/sh
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
RESET=$(tput sgr0)

echo "${GREEN}Enter time period for detecting changes (in seconds): ${RESET}"
read time

# get repo URL from 1st argument
REPO_URL=$1

# check if repo link is provided
if [ -z "$1" ]; then
  echo "${RED}Repo URL not provided as first argument${RESET}"
  exit 1
fi

# check if directory already exists
if [ ! -d "$PWD/app/repo" ]; then
  # clone the repo
  echo "Cloning the repository"
  if ! git clone "$REPO_URL" "$PWD/app/repo"; then
    echo "${RED}Error: Failed to clone the repository. Please check the URL and try again.${RESET}"
    exit 1
  fi
else
  # update the existing repo
  cd $PWD/app/repo
  echo "Pulling the latest commits"
  if ! git pull; then
    echo "${RED}Error: Failed to pull the latest commits. Please check the repository and try again.${RESET}"
    exit 1
  fi
fi

cd $PWD/app/repo

# install dependencies
echo "${GREEN}Installing dependencies${RESET}"
if ! npm install; then
  echo "${RED}Error: Failed to install dependencies. Please check the package.json file and try again.${RESET}"
  exit 1
fi

# build
echo "${GREEN}Building the lastest release${RESET}"
if ! npm run build; then
  echo "${RED}Error: Failed to build the application. Please check the code and try again.${RESET}"
  exit 1
fi

# serve latest release
echo "${GREEN}Serving latest application at http://localhost:3000${RESET}"
nohup serve -s build & > /dev/null

# get the PID of the serve process
SERVE_PID=$!

# monitor the repo, -m is continuous monitoring, -r is recursively look in the directory,
# -e is which type of changes.

# '| while read path action file' part of the command reads the output of inotifywait and
# stores the path, action and file name of each change in the corresponding variable.

inotifywait -m -r -e modify,move,create,delete . | while read path action file; do
    echo "${GREEN}Running again after $time seconds. Sleeping now${RESET}"
    sleep $time

    echo "Pulling the latest commits"

    if git pull | grep -q "Already up to date."; then
      echo "${RED}No new commits to build. Continuing to monitor.${RESET}"
      continue
    fi

    echo "${GREEN}Installing dependencies${RESET}"
    if ! npm install; then
      echo "${RED}Error: Failed to install dependencies. Please check the package.json file and try again.${RESET}"
      continue
    fi

    echo "Building the lastest release"
    if ! npm run build; then
      echo "${RED}Error: Failed to build the application. Please check the code and try again.${RESET}"
      continue
    fi

    kill $SERVE_PID
    echo "${GREEN}Serving latest application at http://localhost:3000${RESET}"
    nohup serve -s build & > /dev/null

    SERVE_PID=$!
done

