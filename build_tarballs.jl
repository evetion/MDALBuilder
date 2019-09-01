using BinaryBuilder


src_version = v"0.3.3"  # also change in raw script string

# Collection of sources required to build GDAL
sources = [
    "https://github.com/lutraconsulting/MDAL/archive/0.3.3.tar.gz" =>
    "9e3081cc3e97156c7fcea0d8039d817fe92ed1846ea0233cf3d676138ebedb1e",
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
mkdir build
cd build
cmake ..
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
    "https://github.com/JuliaGeo/NetCDF.jl/blob/v0.8.0/deps/build.jl",
    "https://github.com/JuliaGeo/GDALBuilder/blob/v2.4.1-0/build_tarballs.jl",
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, "MDAL", src_version, sources, script, platforms, products, dependencies)
