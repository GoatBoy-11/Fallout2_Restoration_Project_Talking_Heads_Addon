#!/bin/bash

set -eu

cd -- "$(dirname "$BASH_SOURCE")"

# is FS case sensitive?
touch fs_testx fs_testX
if [[ "$(ls fs_test* | wc -l)" == "2" ]]; then
  rm -f fs_testx fs_testX
  if [[ "$(find . -name "[[:upper:]]*" | grep -v "mods/AmmoGlovz.ini" | grep -v "mods/AmmoYAAM.ini" | wc -l)" != "0" ]]; then
    echo "The filesystem is case sensitive. You must recursively lowercase Fallout game directory before proceeding."
    exit 1
  fi
else
  rm -f fs_testx
fi

if [[ ! -f master.dat ]]; then
  echo "File master.dat not found. This is not Fallout 2 directory. Aborting."
  exit 1
fi
if [[ -f up-changelog.txt && ! -f rp-changelog.txt ]]; then
  echo "UP installation detected. RPU cannot be installed on UP. Aborting. Re-start with a fresh Fallout 2 installation."
  exit 1
fi
if [[ -f mods/upu.dat ]]; then
  echo "UPU installation detected. RPU cannot be installed on UPU. Aborting. Re-start with a fresh Fallout 2 installation."
  exit 1
fi

bdir="backup/rpu"
mkdir -p "$bdir"/data/sound

if [[ -f patch000.dat ]]; then
  mv patch000.dat "$bdir"/
fi
if [[ -f f2_res.dat ]]; then
  mv f2_res.dat "$bdir"/
fi

# keep savegames, character files, sound
for i in $(ls data | grep -vi "^savegame$\|\.txt$\|\.gcd$\|^sound$"); do
  mv data/"$i" "$bdir"/data/
done
# only need music from sound
for i in $(ls data/sound | grep -vi "^music$"); do
  mv data/sound/"$i" "$bdir"/data/sound/
done

# sfall mods
mkdir -p data/scripts
scripts="
gl_ammomod.int
"
for f in $scripts; do
  mv "$f" data/scripts/
done

# old appearance mod in directories
if [[ -d appearance ]]; then
  for i in $(ls appearance); do
    if [[ -d "$i" ]]; then
      mv appearance/"$i" "$bdir"/
    fi
  done
fi

# sound path fix
rm -f camlrt.dll initool.exe
cp fallout2.cfg "$bdir"/
sed -i.bak 's|music_path1=.*|music_path1=data\\sound\\music\\|' fallout2.cfg
sed -i.bak 's|music_path2=.*|music_path2=sound\\music\\|' fallout2.cfg
rm -f fallout2.cfg.bak

rm -f -- rpu-install.bat rpu-install.command rpu-install.sh

echo "RPU installed. Backup is in $bdir."
