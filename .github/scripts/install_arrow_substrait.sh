cd arrow/cpp
mkdir build_dir
cd build_dir

cmake -DCMAKE_INSTALL_PREFIX=$ARROW_HOME \
      -DCMAKE_INSTALL_LIBDIR=lib -DCMAKE_BUILD_TYPE=Debug  -DARROW_COMPUTE=ON   -DARROW_CSV=ON   -DARROW_DATASET=ON \
      -DARROW_FILESYSTEM=ON   -DARROW_JEMALLOC=ON   -DARROW_JSON=ON   -DARROW_PARQUET=ON   -DARROW_WITH_SNAPPY=ON \
      -DARROW_WITH_ZLIB=ON   -DARROW_INSTALL_NAME_RPATH=OFF   -DARROW_EXTRA_ERROR_CONTEXT=ON \
      -DARROW_INSTALL_NAME_RPATH=OFF -DARROW_DEPENDENCY_SOURCE=BUNDLED -DARROW_SUBSTRAIT=ON ..

make install

cd ../../r/

R CMD INSTALL .
