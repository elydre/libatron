git clone https://github.com/asqel/act.git

echo "Building act..."
cp build_generic.sh act
cd act
bash build_generic.sh ../profanOS "-lpm"
cp act.elf ../build
cd ..
