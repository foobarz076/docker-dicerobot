# DiceRobot Docker 镜像

[![GitHub](https://img.shields.io/github/license/drsanwujiang/docker-dicerobot)](https://github.com/drsanwujiang/dicerobot/blob/main/LICENSE)

## 如何使用

1. 创建容器

    ```shell
    docker pull drsanwujiang/dicerobot
    docker run -d \
        --name dicerobot \
        --publish 9500:9500 \
        --volume /root/dicerobot:/root/dicerobot \
        --volume /root/mirai:/root/mirai \
        --volume /sys/fs/cgroup:/sys/fs/cgroup:ro \
        --privileged dicerobot
    ```

2. 进入容器

    ```shell
    docker exec -it dicerobot /bin/bash
    ```

3. 运行初始化脚本

    ```shell
    bash init.sh
    ```

4. 启动 DiceRobot

    ```shell
    systemctl start dicerobot
    ```

## 镜像列表

- `drsanwujiang/dicerobot:latest`
- `drsanwujiang/dicerobot:3.0.2`
- `drsanwujiang/dicerobot:3.0.1`
- `drsanwujiang/dicerobot:3.0.0`
