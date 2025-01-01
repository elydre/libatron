base="../../.."

git clone https://github.com/asqel/sulfur_lang.git sulfur
cd sulfur
python3 profan_build.py $base/profanOS
cp build/sulfur.elf $base/build
cd ..
rm -rf sulfur
