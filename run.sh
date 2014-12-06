
./build.sh || exit 1


source "./config.sh"


echo -e "\033[0;36mRunning app...\033[0m"
"./$app_bin_path" $@ || {
  echo -e "\033[0;31merror\033[0m"
  exit 1
}
echo -e "\033[0;32mok\033[0m"
