rm -rf act
git clone https://github.com/asqel/act.git

echo "Building act..."
cp build_generic.sh act
cd act
bash build_generic.sh ../profanOS "-lpm"
cp act.elf ../build
cd ..
rm -rf act

rm -rf aledlang
git clone https://github.com/elydre/aledlang.git

echo "Building aledlang..."
cp build_generic.sh aledlang
cd aledlang
bash build_generic.sh ../profanOS
cp aledlang.elf ../build
cd ..
rm -rf aledlang
