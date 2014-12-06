
source "./config.sh"


echo -e "\033[0;36mBuilding app...\033[0m"

# list source files
source_files=$(find src modules -name "*.swift" | grep -iv "tests/" | grep -v "$main_path")
if [ "$1" = "-v" ]; then
  echo -ne "\033[2;37m"
  echo "$source_files"
  echo "$main_path"
  echo -ne "\033[0m"
fi

{
  rm -rf "$app_path"
  mkdir -p "$app_bin_dirname"
  echo "$source_files" | xargs xcrun swiftc -o "$app_bin_path" "$main_path" || exit 1
  chmod +x "$app_path" || exit 1
} || {
  echo -e "\033[0;31merror\033["
  exit 1
}
echo -e "\033[0;32mok\033[0m"
