for e in *.h; do
    # move it to useless/
    mv $e useless/

    # try to compile
    sh profan_compile.sh
    if [ $? -ne 0 ]; then
        # move it back
        mv useless/$e .
    fi
done
