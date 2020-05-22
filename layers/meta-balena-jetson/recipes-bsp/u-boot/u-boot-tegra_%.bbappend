FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

UBOOT_KCONFIG_SUPPORT = "1"

inherit resin-u-boot

RESIN_BOOT_PART_jetson-nano = "0xC"
RESIN_DEFAULT_ROOT_PART_jetson-nano = "0xD"

# Latest L4T 32.4.2 known to work revision of u-boot v2020.04
SRCREV = "914e902b5d68976de59ae0849f2ede20b1f2f50d"

# meta-balena patch does not apply cleanly, so we refactor it
SRC_URI_remove = " file://resin-specific-env-integration-kconfig.patch "
SRC_URI_append = " file://local-resin-specific-env-integration-kconfig.patch "

# These changes are necessary since balenaOS 2.39.0
# for all boards that use u-boot
SRC_URI_append = " \
    file://Increase-default-u-boot-environment-size.patch \
    file://menu-Use-default-menu-entry-from-extlinux.conf.patch \
"

SRC_URI_append_jetson-nano = " \
    file://nano-Integrate-with-Balena-and-load-kernel-from-root.patch \
"

# In l4t 28.2 below partitions were 0xC and 0xD
RESIN_BOOT_PART_jetson-tx2 = "0x18"
RESIN_DEFAULT_ROOT_PART_jetson-tx2 = "0x19"

SRC_URI_append_jetson-tx2 = " \
    file://Add-part-index-command.patch \
    file://tx2-Integrate-with-Balena-u-boot-environment.patch \
"

RESIN_BOOT_PART_jetson-tx1 = "0xB"
RESIN_DEFAULT_ROOT_PART_jetson-tx1 = "0xC"

SRC_URI_append_jetson-tx1 = " \
    file://0001-Add-part-index-command.patch \
    file://tx1-Integrate-with-BalenaOS-environment.patch \
"

# extlinux will now be installed in the rootfs,
# near the kernel, initrd is not used
do_install_append() {
    # Remove generic extlinux.conf added by do_create_extlinux_config()
    rm -rf "${D}/boot/extlinux/extlinux.conf"
    rm -rf "${D}/boot/initrd" \

    install -d ${D}/boot/extlinux
    install -m 0644 ${DEPLOY_DIR_IMAGE}/boot/extlinux.conf ${D}/boot/extlinux/extlinux.conf
    sed -i 's/Image/boot\/Image/g' ${D}/boot/extlinux/extlinux.conf
}

# Free up some space from rootfs
FILES_u-boot-tegra_remove = " \
    /boot/initrd \
"

# Our extlinux is provided by the kernel
do_install[depends] += " virtual/kernel:do_deploy"
