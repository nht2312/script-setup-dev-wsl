#!/bin/bash
set -euo pipefail

# 1. Cài Homebrew nếu chưa có
if ! command -v brew >/dev/null 2>&1; then
  echo "▶ Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
fi

# 2. Nạp lại biến môi trường Homebrew cho phiên hiện tại
eval "$(/opt/homebrew/bin/brew shellenv)"

# 3. Cập nhật & cài package cần dùng (dùng node@20 để tránh lỗi module cjs mới)
echo "▶ Updating Homebrew..."
brew update

echo "▶ Installing PHP, Node, Git, Composer..."
brew install php node@24 git composer

# Node@20 cần link thủ công nếu dùng default “node”
brew unlink node || true
brew link --overwrite node@20

# 4. Đảm bảo intl extension đã bật (brew PHP mặc định kèm sẵn)
php -m | grep -q intl || {
  echo "⚠️ PHP intl extension chưa bật. Chạy 'brew reinstall php' rồi kiểm tra lại."
}

# 5. Composer global bin vào PATH
COMPOSER_HOME="$(composer config -g data-dir 2>/dev/null || echo "$HOME/.composer")"
if ! grep -q 'composer/vendor/bin' "$HOME/.zprofile"; then
  echo 'export PATH="$PATH:'"$COMPOSER_HOME"'/vendor/bin"' >> "$HOME/.zprofile"
fi
export PATH="$PATH:$COMPOSER_HOME/vendor/bin"

# 6. Cài Laravel installer
echo "▶ Installing Laravel installer..."
composer global require laravel/installer

echo "✅ Hoàn tất! Đừng quên mở session shell mới hoặc chạy: source ~/.zprofile"

ssh-keygen -t rsa -b 4096 -C "...@gmail.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub

echo 'Use: ssh -T git@github.com'
echo 'git config --global user.name "name"'
echo 'git config --global user.email <email>'
