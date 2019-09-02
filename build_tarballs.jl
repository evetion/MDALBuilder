using BinaryBuilder

# Collection of sources required to build MDAL
sources = [
    "https://github.com/lutraconsulting/MDAL/archive/0.3.3.tar.gz" =>
    "9e3081cc3e97156c7fcea0d8039d817fe92ed1846ea0233cf3d676138ebedb1e",
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd MDAL-0.3.3
mkdir build
cd build
cmake \
    -DCMAKE_INSTALL_PREFIX=$prefix \
    -DCMAKE_TOOLCHAIN_FILE=/opt/$target/$target.toolchain \
    -DHDF5_ROOT=/ \
    -DWITH_HDF5=OFF \
    -DWITH_GDAL=OFF \
    -DWITH_NETCDF=OFF \
    -DWITH_XML=OFF \
    -HDF5_LIBRARIES=/lib64/ \
    -DHDF5_INCLUDE_DIRS=/include/ \
    -DGDAL_DIR=$WORKSPACE/destdir \
    -DGDAL_INCLUDE_DIR=$WORKSPACE/destdir/include \
    -DCMAKE_BUILD_TYPE=Rel \
    ..
make -j8
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
  BinaryProvider.Windows(:i686),
  BinaryProvider.Windows(:x86_64),
  BinaryProvider.MacOS(),
  BinaryProvider.Linux(:x86_64, :glibc),
  BinaryProvider.Linux(:i686, :glibc),
]
platforms = expand_gcc_versions(platforms)

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libmdal", :libmdal),
    ExecutableProduct(prefix, "mdalinfo", :mdalinfo),
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "https://raw.githubusercontent.com/JuliaGeo/GDAL.jl/v0.2.0/deps/build_GEOS.v3.6.2.jl",
    "https://raw.githubusercontent.com/JuliaGeo/GDAL.jl/v0.2.0/deps/build_PROJ.v4.9.3.jl",
    "https://raw.githubusercontent.com/JuliaGeo/GDAL.jl/v0.2.0/deps/build_Zlib.v1.2.11.jl",
    "https://raw.githubusercontent.com/JuliaIO/HDF5.jl/v0.11.1/deps/build.jl",
    BinaryBuilder.InlineBuildDependency(read("deps/build_GDAL.jl", String)),
    BinaryBuilder.InlineBuildDependency(read("deps/build_HDF5.jl", String))
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, "MDAL", v"0.3.3", sources, script, platforms, products, dependencies)
