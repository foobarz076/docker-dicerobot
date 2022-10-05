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

  printf "\n****************************************\n"
  printf "%-15s   %-20s\n" " QQ 号码" "   QQ 密码"
  printf "****************************************\n"
  printf "%-15s   %-20s\n" "${MIRAI_USER_ID}" "${MIRAI_USER_PASSWORD}"
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

wget -O /tmp/mirai.zip https://dl.drsanwujiang.com/dicerobot/mirai/mirai-mcl-2.3.1.zip

if [ $? -ne 0 ]; then
  process_failed "下载 Mirai 失败"
fi

unzip -o /tmp/mirai.zip -d /mirai
rm -f /tmp/mirai.zip

printf "\nDone\n\n"

# Deploy DiceRobot
printf "\033[32m3. 部署 DiceRobot\033[0m\n"

if [ "$(ls -A /dicerobot)" = "" ]; then
  composer --no-interaction create-project drsanwujiang/dicerobot-skeleton:3.1.0 /dicerobot --no-dev

  if [ $? -ne 0 ]; then
    process_failed "部署 DiceRobot 失败"
  fi
else
  printf "\033[33m检测到 DiceRobot 目录不为空，更新 DiceRobot……\033[0m\n"

  wget -O /tmp/dicerobot-update.zip https://dl.drsanwujiang.com/dicerobot/skeleton-update/skeleton-update-3.1.0.zip

  if [ $? -ne 0 ]; then
    process_failed "下载 DiceRobot 更新包失败"
  fi

  unzip -o /tmp/dicerobot-update.zip -d /dicerobot
  composer --no-interaction update --working-dir /dicerobot --no-dev

  if [ $? -ne 0 ]; then
    process_failed "更新 DiceRobot 失败"
  fi
fi

printf "\nDone\n\n"

# Initialization
printf "\033[32m4. 初始化\033[0m\n"

cat > /dicerobot/config/custom_config.php <<EOF
<?php

use Monolog\Logger;

/**
 * 自定义配置
 */

/******************************************************************************
 *                                    必填项                                   *
 ******************************************************************************/

/**
 * 在这里填写机器人的 QQ 号，以及 Mirai API HTTP 插件中的 Auth Key
 */
$settings["mirai"]["robot"] = [
    "id" => ${MIRAI_USER_ID},
    "authKey" => "12345678"
];

/******************************************************************************
 *                                    常用项                                   *
 ******************************************************************************/

/**
 * 在这里填写 Mirai API HTTP 插件监听的端口
 */
$settings["mirai"]["server"]["host"] = "mirai";
$settings["mirai"]["server"]["port"] = 8080;

/**
 * 在这里填写 DiceRobot 监听的端口
 */
$settings["dicerobot"]["server"]["port"] = 9500;

/**
 * 在这里设置日志等级，file 表示日志文件的等级，console 表示控制台日志的等级
 */
$settings["log"]["level"] = [
    "file" => Logger::NOTICE,
    "console" => Logger::NOTICE
];
EOF

cat > /mirai/config/Console/AutoLogin.yml <<EOF
accounts:
  -
    account: ${MIRAI_USER_ID}
    password:
      kind: PLAIN
      value: ${MIRAI_USER_PASSWORD}
    configuration:
      protocol: ANDROID_PHONE
EOF

cat > /mirai/config/net.mamoe.mirai-api-http/setting.yml <<EOF
adapters:
  - http
  - webhook

enableVerify: false
verifyKey: 12345678

singleMode: true

cacheSize: 4096

adapterSettings:
  http:
    host: 0.0.0.0
    port: 8080
    cors:
      - *

  webhook:
    destinations:
      - "http://dicerobot:9500/report"
EOF

printf "\nDone\n\n"

# Normal termination
printf "======================================================================================================\n\n"
printf "DiceRobot 及其运行环境已经初始化完毕，接下来请依照说明文档运行 DiceRobot 及 Mirai 即可\n"
