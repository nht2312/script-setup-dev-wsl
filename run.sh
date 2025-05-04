#!/bin/bash

echo "🔧 Bắt đầu quá trình cài đặt môi trường phát triển..."

# Cập nhật hệ thống
sudo apt update && sudo apt upgrade -y

# Cài các công cụ cơ bản
sudo apt install -y curl wget gnupg2 lsb-release software-properties-common unzip zip build-essential \
libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncursesw5-dev \
xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

# --- PHP & Composer ---
echo "📦 Đang cài đặt PHP 8.3 và Composer..."

# Thêm PPA cho PHP
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update

# Cài PHP 8.3 và extension cần thiết
sudo apt install -y php8.3 php8.3-cli php8.3-common php8.3-mbstring php8.3-xml php8.3-curl php8.3-mysql \
php8.3-bcmath php8.3-zip php8.3-gd php8.3-intl php8.3-soap php8.3-readline php8.3-pgsql php8.3-sqlite3 \
php8.3-imap php8.3-opcache php8.3-xdebug php8.3-dev

# Đặt PHP 8.3 làm mặc định
sudo update-alternatives --set php /usr/bin/php8.3

# Cài Composer
cd ~
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php --install-dir=/usr/local/bin --filename=composer
rm composer-setup.php

# Thêm Composer vào PATH
echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# --- Node.js ---
echo "📦 Đang cài đặt Node.js LTS..."
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

# --- Python 3.12 ---
echo "🐍 Đang cài đặt Python 3.12 và pip..."
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update
sudo apt install -y python3.12 python3.12-venv python3.12-dev python3-distutils

# Đặt Python và pip làm mặc định
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1
sudo update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# Cài pip cho Python 3.12
curl -sS https://bootstrap.pypa.io/get-pip.py | sudo python3.12

# Cài virtualenv
pip install virtualenv

# --- Git & SSH ---
echo "🔐 Đang cài đặt Git và thiết lập SSH..."

# Cài Git
sudo apt install -y git

# Hỏi người dùng nhập thông tin Git
read -p "📝 Nhập tên Git (user.name): " git_username
read -p "📧 Nhập email Git (user.email): " git_email

# Cấu hình Git
git config --global user.name "$git_username"
git config --global user.email "$git_email"
git config --global core.editor "nano"

# Hiển thị cấu hình Git
echo "✅ Đã cấu hình Git:"
git config --global --list

# Tạo SSH key nếu chưa có
if [ ! -f ~/.ssh/id_rsa.pub ]; then
    echo "🔐 Chưa có SSH key, đang tạo mới..."
    ssh-keygen -t rsa -b 4096 -C "$git_email" -N "" -f ~/.ssh/id_rsa
else
    echo "🔐 SSH key đã tồn tại."
fi

# Thêm SSH key vào ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

# In SSH key để copy lên GitHub
echo ""
echo "👉 Dưới đây là SSH public key của bạn. Hãy copy và thêm vào GitHub:"
echo ""
cat ~/.ssh/id_rsa.pub
echo ""
echo "🔗 Link thêm SSH key GitHub: https://github.com/settings/keys"

echo ""
echo "📌 Sau khi đã thêm SSH key vào GitHub, hãy kiểm tra kết nối bằng lệnh sau:"
echo "    ssh -T git@github.com"
echo ""
echo "✅ Nếu mọi thứ OK, bạn sẽ thấy thông báo:"
echo "    Hi username! You've successfully authenticated, but GitHub does not provide shell access."

# --- Kiểm tra lại ---
echo "✅ Kiểm tra phiên bản đã cài:"
php -v
composer -V
node -v
npm -v
python --version
pip --version
git --version

echo ""
echo "🎉 Quá trình cài đặt hoàn tất! Môi trường dev của bạn đã sẵn sàng."
