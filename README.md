# neo

🐇 **[`Follow the white rabbit.`](https://dev.to/francescobianco/matrix-public-task-runner-1ek2)**

[![Build Status](https://travis-ci.org/zionrc/neo.svg?branch=master)](https://travis-ci.org/zionrc/neo)

Neo is the command-line utility behind [Zionrc](https://zionrc.github.io) project.

![neo](neo.gif)

## Installation

```bash
curl -sL git.io/zion | sudo bash -
```

## Usage

```bash
neo run matrix
```

## Testing

docker-compose run --rm test

## Url shortening

```bash
curl -i https://git.io \
     -F "url=https://raw.githubusercontent.com/zionrc/neo/master/setup.sh" \
     -F "code=zion"
```
