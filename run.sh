rm -rf  build
rm lib/wrapper/*.c
rm lib/wrapper/*.pyd
rm $(find lib/wrapper/utils/ -name "*.c" -not -name "LinkedList.c")
rm lib/wrapper/utils/*.pyd
python setup.py build_ext --inplace
