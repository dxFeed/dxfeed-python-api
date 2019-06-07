rm -rf  build
rm lib/wrapper/*.c
rm lib/wrapper/*.pyd
python setup.py build_ext --inplace
