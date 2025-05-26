#!/bin/bash

echo "🔧 Bắt đầu quá trình cài đặt môi trường phát triển..."

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Vui lòng chạy script với quyền root (sudo)"
  exit 1
fi

# Cập nhật hệ thống
apt update && apt upgrade -y

# Cài các công cụ cơ bản
apt install -y curl wget gnupg2 lsb-release software-properties-common unzip zip build-essential \
libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncursesw5-dev \
xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev ca-certificates

# --- PHP & Composer ---
echo "📦 Đang cài đặt PHP 8.3 và Composer..."

add-apt-repository ppa:ondrej/php -y
apt update

apt install -y php8.3 php8.3-cli php8.3-common php8.3-mbstring php8.3-xml php8.3-curl php8.3-mysql \
php8.3-bcmath php8.3-zip php8.3-gd php8.3-intl php8.3-soap php8.3-readline php8.3-pgsql php8.3-sqlite3 \
php8.3-imap php8.3-opcache php8.3-xdebug php8.3-dev

update-alternatives --set php /usr/bin/php8.3

# Cài Composer nếu chưa có
if ! command -v composer &> /dev/null; then
    echo "📦 Cài Composer..."
    cd ~
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    rm composer-setup.php
else
    echo "✅ Composer đã tồn tại."
fi

# Thêm Composer vào PATH nếu chưa có
if ! grep -q 'composer/vendor/bin' ~/.bashrc; then
    echo 'export PATH="$HOME/.composer/vendor/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
fi

# --- Node.js ---
echo "📦 Đang kiểm tra Node.js..."
if ! command -v node &> /dev/null; then
    echo "📦 Đang cài đặt Node.js LTS..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
    apt install -y nodejs
else
    echo "✅ Node.js đã được cài đặt."
fi

# --- Python 3.12 ---
echo "🐍 Cài đặt Python 3.12 và pip..."
add-apt-repository ppa:deadsnakes/ppa -y
apt update
apt install -y python3.12 python3.12-venv python3.12-dev python3-distutils

update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1
update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# Cài pip cho Python 3.12 nếu chưa có
if ! python3.12 -m pip &> /dev/null; then
    curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12
fi

pip install virtualenv

# --- Git & SSH ---
echo "🔐 Cài đặt Git và thiết lập SSH..."

apt install -y git

read -p "📝 Nhập tên Git (user.name): " git_username
read -p "📧 Nhập email Git (user.email): " git_email

git config --global user.name "$git_username"
git config --global user.email "$git_email"
git config --global core.editor "nano"

echo "✅ Đã cấu hình Git:"
git config --global --list

# Tạo SSH key nếu chưa có
if [ ! -f ~/.ssh/id_rsa.pub ]; then
    echo "🔐 Chưa có SSH key, đang tạo mới..."
    ssh-keygen -t rsa -b 4096 -C "$git_email" -N "" -f ~/.ssh/id_rsa
else
    echo "🔐 SSH key đã tồn tại."
fi

eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

echo ""
echo "👉 SSH public key của bạn (dán vào GitHub):"
cat ~/.ssh/id_rsa.pub
echo ""
echo "🔗 Thêm SSH key vào GitHub: https://github.com/settings/keys"
echo ""
echo "📌 Kiểm tra kết nối GitHub sau khi thêm key:"
echo "    ssh -T git@github.com"

# --- Kiểm tra lại ---
echo ""
echo "✅ Phiên bản đã cài:"
php -v
composer -V
node -v
npm -v
python --version
pip --version
git --version

echo ""
echo "🎉 Xong rồi fen ơi! Môi trường dev đã sẵn sàng để triển chiến."
