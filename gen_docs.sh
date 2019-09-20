rm -rf  build
rm -rf  docs/_build
rm $(find dxpyfeed/wrapper/ -name "*.c")
rm $(find dxpyfeed/wrapper/ -name "*.pyd")
rm $(find dxpyfeed/wrapper/ -name "*.so")
python generate_docs.py build_clib build_ext --inplace
cd docs
make html
cd ..
rm $(find dxpyfeed/wrapper/ -name "*.c")
rm $(find dxpyfeed/wrapper/ -name "*.pyd")
rm $(find dxpyfeed/wrapper/ -name "*.so")