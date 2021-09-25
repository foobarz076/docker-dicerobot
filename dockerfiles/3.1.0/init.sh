#!/bin/bash

function exceptional_termination() {
  printf "======================================================================================================\n\n"
  printf "脚本意外终止\n"
  exit 1
}

function process_failed() {
  printf "\033[31m%s\033[0m\n\n" "$1"
  exceptional_termination
}

printf "======================================================================================================\n"
printf "\033[32m                                    DiceRobot Docker 初始化脚本\033[0m\n"
printf "======================================================================================================\n\n"

# Input QQ account profile
printf "\033[32m1. 输入 QQ 账号信息\033[0m\n"

while true
do
  read -r -p "请输入机器人的 QQ 号码: " qq_id
  read -r -p "请输入机器人的 QQ 密码: " qq_password

  printf "\n****************************************\n"
  printf "%-15s   %-20s\n" " QQ 号码" "   QQ 密码"
  printf "****************************************\n"
  printf "%-15s   %-20s\n" "${qq_id}" "${qq_password}"
  printf "****************************************\n"
  printf "\033[33m请确认以上信息是否正确？\033[0m [Y/N] "
  read -r is_correct
  printf "\n"

  case $is_correct in
    [yY][eE][sS]|[yY])
      break
      ;;

    *)
      ;;
  esac
done

printf "Done\n\n"

# Check environment
printf "\033[32m2. 检查 DiceRobot 运行环境\033[0m\n"

if ! (php -v > /dev/null 2>&1); then
  process_failed "未检测到 PHP"
fi

if ! (php --ri swoole > /dev/null 2>&1); then
  process_failed "未检测到 Swoole"
fi

if ! (java --version > /dev/null 2>&1); then
  process_failed "未检测到 Java"
fi

printf "\nDone\n\n"

# Deploy Mirai
printf "\033[32m3. 部署 Mirai\033[0m\n"

wget -qO mirai.zip https://dl.drsanwujiang.com/dicerobot/mirai/mirai-mcl-2.3.1.zip

if [ $? -ne 0 ]; then
  process_failed "下载 Mirai 失败"
fi

unzip -qq -o mirai.zip -d mirai
rm -f mirai.zip

printf "\nDone\n\n"

# Deploy DiceRobot
printf "\033[32m3. 部署 DiceRobot\033[0m\n"

if [ "$(ls -A dicerobot)" = "" ]; then
  composer --no-interaction --quiet create-project drsanwujiang/dicerobot-skeleton:3.1.0 dicerobot --no-dev

  if [ $? -ne 0 ]; then
    process_failed "部署 DiceRobot 失败"
  fi
else
  printf "\033[33m检测到 DiceRobot 目录不为空，更新 DiceRobot……\033[0m\n"

  wget -qO dicerobot-update.zip https://dl.drsanwujiang.com/dicerobot/skeleton-update/skeleton-update-3.1.0.zip

  if [ $? -ne 0 ]; then
    process_failed "下载 DiceRobot 更新包失败"
  fi

  unzip -qq -o dicerobot-update.zip -d dicerobot
  composer --no-interaction --quiet update --working-dir dicerobot --no-dev

  if [ $? -ne 0 ]; then
    process_failed "更新 DiceRobot 失败"
  fi
fi

printf "\nDone\n\n"

# Initialization
printf "\033[32m4. 初始化\033[0m\n"

sed -i "0,/10000/{s/10000/${qq_id}/}" dicerobot/config/custom_config.php

cat > mirai/config/Console/AutoLogin.yml <<EOF
accounts:
  -
    account: ${qq_id}
    password:
      kind: PLAIN
      value: ${qq_password}
    configuration:
      protocol: ANDROID_PHONE
EOF

cat > mirai/config/net.mamoe.mirai-api-http/setting.yml <<EOF
adapters:
  - http
  - webhook

enableVerify: false
verifyKey: 12345678

singleMode: true

cacheSize: 4096

adapterSettings:
  http:
    host: 127.0.0.1
    port: 8080
    cors:
      - *

  webhook:
    destinations:
      - "http://127.0.0.1:9500/report"
EOF

cat > /etc/systemd/system/dicerobot.service <<EOF
[Unit]
Description=A TRPG dice robot based on Swoole
After=network.target
After=syslog.target
Before=mirai.service

[Service]
User=$(id -un)
Group=$(id -gn)
Type=simple
ExecStart=/usr/local/bin/php /root/dicerobot/dicerobot.php
ExecReload=/bin/kill -12 \$MAINPID
RestartSec=1s
RestartForceExitStatus=99

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/mirai.service <<EOF
[Unit]
Description=Mirai Console
After=network.target
After=syslog.target
After=dicerobot.service

[Service]
Type=simple
Environment="PATH=/opt/java/openjdk/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
WorkingDirectory=/root/mirai
ExecStart=/bin/bash /root/mirai/start-mirai.sh
ExecStop=/bin/bash /root/mirai/stop-mirai.sh

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload > /dev/null 2>&1
systemctl enable dicerobot > /dev/null 2>&1
systemctl enable mirai > /dev/null 2>&1

printf "\nDone\n\n"

# Normal termination
printf "======================================================================================================\n\n"
printf "DiceRobot 及其运行环境已经初始化完毕，接下来请依照说明文档运行 DiceRobot 及 Mirai 即可\n"
