
if [ ! -f "swiftmodule.json" ]; then
  cd /tmp
  git clone git://github.com/jankuca/swm.git swm
  cd swm
  ./install.sh || exit 1
  exit 0
fi


if [ ! -d "modules/JSON" ]; then
  git clone git://github.com/dankogai/swift-json.git modules/JSON
fi

./build.sh
cp build/app /usr/local/bin/swm
