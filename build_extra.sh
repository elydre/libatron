rm -rf aledlang
git clone https://github.com/elydre/aledlang.git

echo "Building aledlang..."
cp build_generic.sh aledlang
cd aledlang
bash build_generic.sh ../profanOS
cp aledlang.elf ../build
cd ..
rm -rf aledlang
