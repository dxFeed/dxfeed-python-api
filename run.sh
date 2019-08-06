rm -rf  build
rm lib/wrapper/*.c
rm lib/wrapper/*.pyd
rm $(find lib/wrapper/linked_list/ -name "*.c" -not -name "LinkedList.c")
rm lib/wrapper/utils/*.pyd
rm lib/wrapper/utils/*.c
rm lib/wrapper/linked_list/*.pyd
python setup.py build_ext --inplace
