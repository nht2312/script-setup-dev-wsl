/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

brew install php && brew install node && brew install git && brew install composer && composer global require laravel/installer

ssh-keygen -t rsa -b 4096 -C "...@gmail.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub

echo 'Use: ssh -T git@github.com'
echo 'git config --global user.name "name"'
echo 'git config --global user.email <email>'
