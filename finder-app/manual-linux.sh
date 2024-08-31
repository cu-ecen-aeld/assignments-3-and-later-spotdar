#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.15.163
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    # TODO: Add your kernel build steps here
    #mrproper i.e. clean command
    echo "RUNNING COMMAND --> clean aka mrproper"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper

    #defconfig
    echo "RUNNING COMMAND --> make defconfig"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig

    #vmlinux target
    echo "RUNNING COMMAND --> make all"
    make -j32 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} all

    #modules and devicetree
    echo "RUNNING COMMAND --> make modules and devicetrees"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} dtbs

fi

echo "Adding the Image in outdir"
cp ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ${OUTDIR}

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
echo "RUNNING COMMAND --> mkdir basedirctorties" 
mkdir ${OUTDIR}/rootfs 
cd rootfs
mkdir -p bin dev etc home lib lib64 proc sbin sys tmp usr var
mkdir -p usr/bin usr/lib usr/sbin
mkdir -p var/log

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
    # echo "RUNNING COMMAND --> configure busybox-> distclean ->defconfig" 
     make distclean
     make defconfig

else
    cd busybox
fi

# # TODO: Make and install busybox
 echo "RUNNING COMMAND --> make busybox" 
 make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
 make CONFIG_PREFIX=${OUTDIR}/rootfs ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install

 cd ${OUTDIR}/rootfs
 echo "Library dependencies"
 ${CROSS_COMPILE}readelf -a bin/busybox | grep "program interpreter"
 ${CROSS_COMPILE}readelf -a bin/busybox | grep "Shared library"

# # TODO: Add library dependencies to rootfs
echo "RUNNING COMMAND -->Copying lib files from arm sysroot to rootfd"
armsysroot=$(${CROSS_COMPILE}gcc -print-sysroot)
cp -L ${armsysroot}/lib/ld-linux-aarch64.* -t ${OUTDIR}/rootfs/lib #program interpreter
cp -L ${armsysroot}/lib64/libm.* -t ${OUTDIR}/rootfs/lib64
cp -L ${armsysroot}/lib64/libresolv.* -t ${OUTDIR}/rootfs/lib64
cp -L ${armsysroot}/lib64/libc.* -t ${OUTDIR}/rootfs/lib64


# # TODO: Make device nodes
echo "RUNNING COMMAND -->mknod for device nodes"
sudo mknod -m 666 dev/null c 1 3
sudo mknod -m 600 dev/console c 5 1

# # TODO: Clean and build the writer utility
echo "RUNNING COMMAND -->clean and make finder app"
assignments_finderapp=~/coursera_aeld/aeld_assignments/assignment-1-spotdar/finder-app
cd ${assignments_finderapp}
make clean #clean
make CROSS_COMPILE=${CROSS_COMPILE}   #build


# # TODO: Copy the finder related scripts and executables to the /home directory
# # on the target rootfs
echo "RUNNING COMMAND -->copy finder app related stuff to rootfs"
cp -L ${assignments_finderapp}/autorun-qemu.sh -t ${OUTDIR}/rootfs/home/
cp -L ${assignments_finderapp}/dependencies.sh -t ${OUTDIR}/rootfs/home/
cp -L ${assignments_finderapp}/finder-test.sh -t ${OUTDIR}/rootfs/home/
cp -L ${assignments_finderapp}/finder.sh -t ${OUTDIR}/rootfs/home/
cp -r ${assignments_finderapp}/conf/ -t ${OUTDIR}/rootfs/home/
cp -L ${assignments_finderapp}/writer ${OUTDIR}/rootfs/home/

# # TODO: Chown the root directory
echo "RUNNING COMMAND -->Chown the root directory"
cd ${OUTDIR}/rootfs
sudo chown -R root:root *

# # TODO: Create initramfs.cpio.gz
echo "RUNNING COMMAND -->Create initramfs.cpio.gz"
cd ${OUTDIR}/rootfs
find . | cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio
cd ${OUTDIR}
gzip -f initramfs.cpio
echo "END OF manual-linux.sh SCRIPT"