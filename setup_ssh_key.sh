#!/bin/bash
# 在 CardputerZero 上执行此脚本以配置 SSH 免密登录

set -e

echo "配置 SSH 免密登录..."

# 创建 .ssh 目录
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "✓ 创建 ~/.ssh 目录"

# 添加公钥
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZQFow2c8SLdZK2iztpE88xHcQhYUxi/pKLlLomNb1x ppatdelphi@outlook.com" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
echo "✓ 添加公钥到 authorized_keys"

echo ""
echo "配置完成！现在可以从你的电脑免密登录："
echo "  ssh cardputer"
echo ""
