#!/usr/bin/env sh

# Exit if any subcommand fails
set -e

printf "\n=================== adding VSCode cli to PATH ===================\n"
if command -v code > /dev/null; then
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
  exit 1
fi

printf "\n============== installing solargraph extension ================\n"
code --install-extension castwide.solargraph

printf "\n================= installing solargraph gem ===================\n"
gem install solargraph

if [ ! -f .solargraph.yml ]; then
  printf "\n==================== adding .solargraph.yml =====================\n"
  touch .solargraph.yml
  echo "include:" > .solargraph.yml
  echo "- \"app/**/*.rb\"" >> .solargraph.yml
  echo "- \"spec/**/*.rb\"" >> .solargraph.yml
fi

printf "\n====================== installing gem docs ======================\n"
yard gems || true

printf "\n================ setting gem docs to auto-install ===============\n"
yard config --gem-install-yri

if [ ! -f config/definitions.rb ]; then
  printf "\n================= adding config/definitions.rb ==================\n"
  touch config/definitions.rb
  url='https://gist.githubusercontent.com/castwide/28b349566a223dfb439a337aea29713e/raw/715473535f11cf3eeb9216d64d01feac2ea37ac0/rails.rb'
  html=$( curl -# -L "${url}" 2> '/dev/null' )
  echo "${html}" > config/definitions.rb
fi

printf "\n========================= installing NPM ========================\n"
NPM_INSTALLED=$(command asdf plugin list all | grep -c npm)
if [ $NPM_INSTALLED -gt 0 ]; then
  printf "npm plugin for asdf is already added!\n"
else
  printf "npm plugin for asdf was NOT found. Adding plugin!\n"
  asdf plugin add npm
fi

printf "\n====================== installing NPM json ======================\n"
if command -v json > /dev/null; then
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

printf "\n================= updating Solargraph settings ==================\n"
json -I -f "${settings_path}" -e "this[\"solargraph.commandPath\"]=\"$solargraphpath\""
json -I -f "${settings_path}" -e "this[\"solargraph.useBundler\"]=false"

printf "\n==============================================================="
printf "\n==-------------------- SETUP COMPLETE!! ---------------------=="
printf "\n==-------------------- CONGRATULATIONS! ---------------------=="
printf "\n==============================================================="
printf "\n============== Please reload your VSCode Window ===============\n"