{ lib, stdenv, kernel, fetchFromGitHub, kernelPatches, ...}:

stdenv.mkDerivation rec {
  pname = "macbook12-audio-driver";
  version = "2023-01-31";

  src = fetchFromGitHub {
    owner = "leifliddy";
    repo = "macbook12-audio-driver";
    rev = "004c50141bc03180835f6e35ca8de96ef9d81819";
    sha256 = "sha256-OGz2pugF64W7qFDm+QcoS078jGU/6G02PgZsgTnZObA=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;
  makeFlags = kernel.makeFlags;

  patches = [ ./0001-makefile.patch ];

  buildPhase = ''
    cd patch_cirrus
    ls ${kernel}/lib
    cp ${kernel.dev}/lib/modules/${kernel.modDirVersion}/source/sound/pci/hda/hda_local.h .
    cp ${kernel.dev}/lib/modules/${kernel.modDirVersion}/source/sound/pci/hda/hda_auto_parser.h .
    cp ${kernel.dev}/lib/modules/${kernel.modDirVersion}/source/sound/pci/hda/hda_jack.h .
    cp ${kernel.dev}/lib/modules/${kernel.modDirVersion}/source/sound/pci/hda/hda_generic.h .
    ls $(pwd)
    ls ${kernel.dev}/lib
    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
      -j$NIX_BUILD_CORES M=$(pwd) modules $makeFlags
  '';

  installPhase = ''
    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build  \
      INSTALL_MOD_PATH=$out M=$(pwd) modules_install $makeFlags
  '';

  meta = with lib; {
    description = "WIP audio driver for the cs4208 codec found in the 12 inch MacBook (MacBook9,1, MacBook10,1).";
    homepage = "https://github.com/leifliddy/macbook12-audio-driver";
    license = lib.licenses.gpl2Only;
    platforms = platforms.linux;
    maintainers = [ lib.maintainers.f2k1de ];
    broken = kernel.kernelOlder "5.6";
  };
}
