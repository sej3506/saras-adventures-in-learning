#!/usr/bin/env sh

# Exit if any subcommand fails
set -e

echo '\n=========== adding VSCode cli to PATH ===========\n'
if command -v code; then
  printf "VSCode cli is already installed!\n"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  printf "VSCode cli is NOT installed. Starting setup!\n"

  # https://code.visualstudio.com/docs/setup/mac
  cat << EOF >> ~/.zprofile
  export PATH="\$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
EOF

  reset
else
  printf "Currently only supporting adding CLI to PATH for macOS.\n"
  printf "Check out instructions for your OS here https://code.visualstudio.com/docs/setup/setup-overview\n"
fi

echo '\n=== installing solargraph extension ===\n'
code --install-extension castwide.solargraph

echo '\n================ installing solargraph gem ================\n'
gem install solargraph

if [ ! -f .solargraph.yml ]; then
  echo '\n================ adding .solargraph.yml ================\n'
  touch .solargraph.yml
  echo "include:" > .solargraph.yml
  echo "- \"app/**/*.rb\"" >> .solargraph.yml
  echo "- \"spec/**/*.rb\"" >> .solargraph.yml
fi

echo '\n================ installing gem docs ================\n'
yard gems

echo '\n================ setting gem docs to auto-install ================\n'
yard config --gem-install-yri

if [ ! -f config/definitions.rb ]; then
  echo '\n================ adding config/definitions.rb ================\n'
  touch config/definitions.rb
  url='https://gist.githubusercontent.com/castwide/28b349566a223dfb439a337aea29713e/raw/715473535f11cf3eeb9216d64d01feac2ea37ac0/rails.rb'
  html=$( curl -# -L "${url}" 2> '/dev/null' )
  echo "${html}" > config/definitions.rb
fi

echo '\n================ installing NPM ================\n'
NPM_INSTALLED=$(command asdf plugin list all | grep -c npm)
if [ $NPM_INSTALLED -gt 0 ]; then
  printf "npm plugin for asdf is already added!\n"
else
  printf "npm plugin for asdf was NOT found. Adding plugin!\n"
  asdf plugin add npm
fi

echo '\n================ installing NPM json ================\n'
if command -v json; then
  printf "npm json is already installed!\n"
else
  printf "npm json is NOT installed. Starting setup!\n"
  npm install -g json
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  settings_path="$HOME/Library/Application Support/Code/User/settings.json"
elif [[ "$OSTYPE" == "msys" ]]; then
  # Windows
  settings_path="%APPDATA%\Code\User\settings.json"
else
  # Linux or ¯\_(ツ)_/¯
  settings_path="$HOME/.config/Code/User/settings.json"
fi

solargraphpath=$(command -v solargraph)

echo '\n================ updating Solargraph settings ================\n'
json -I -f "${settings_path}" -e "this[\"solargraph.commandPath\"]=\"$solargraphpath\""
json -I -f "${settings_path}" -e "this[\"solargraph.useBundler\"]=false"

echo '\n=============================================='
echo '==------------ SETUP COMPLETE!! ------------=='
echo '==------------ CONGRATULATIONS! ------------=='
echo '==============================================\n'
echo '====== Please reload your VSCode Window ======\n'