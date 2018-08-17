#!/bin/sh
#
# Copyright (c) 2016 Nest Labs, Inc.
# All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

PREV_PATH="`pwd`"

die()
{
	echo " *** ERROR: " $*
	exit 1
}

#######################################
# Prepare android build system
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
android_prepare_build_system()
{
    # Android build system
    (mkdir build && cd build && git init && git pull --depth 1 https://android.googlesource.com/platform/build 2db32730e79cafcf13e1f898a7bee7f82b0449d6)
    ln -s build/core/main.mk Makefile

    # Workarounds for java checking
    export ANDROID_JAVA_HOME=/usr/lib/jvm/java-8-oracle
    mkdir bin
    cat > bin/java <<EOF
#!/bin/sh
echo java version \"1.6\"
EOF

    cat > bin/javac <<EOF
echo javac \"1.6\"
EOF
    chmod a+x bin/java bin/javac
    export PATH=$(pwd)/bin:$PATH

    # Files for building ndk
    mkdir -p system/core/include/arch/linux-arm
    touch system/core/include/arch/linux-arm/AndroidConfig.h

    mkdir -p system/core/include/arch/linux-x86
    touch system/core/include/arch/linux-x86/AndroidConfig.h

    ANDROID_NDK_PATH=$(dirname $(which sdkmanager))/../../ndk-bundle
    mkdir -p bionic/libc/
    cp -r $ANDROID_NDK_PATH/sysroot/usr/include bionic/libc/include
    mv bionic/libc/include/arm-linux-androideabi/asm bionic/libc/include/asm

    mkdir -p out/target/product/generic/obj/
    cp -r $ANDROID_NDK_PATH/platforms/android-27/arch-arm/usr/lib out/target/product/generic/obj/

    mkdir -p bionic/libstdc++
    cp -r $ANDROID_NDK_PATH/sources/cxx-stl/gnu-libstdc++/4.9/include bionic/libstdc++
    cp -r $ANDROID_NDK_PATH/sources/cxx-stl/gnu-libstdc++/4.9/libs/armeabi-v7a/include/* bionic/libstdc++/include
    # The default libstdc++.so does not contain full stl implementation, see https://developer.android.com/ndk/guides/cpp-support
    cp -r $ANDROID_NDK_PATH/sources/cxx-stl/gnu-libstdc++/4.9/libs/armeabi-v7a/libgnustl_shared.so out/target/product/generic/obj/lib/libstdc++.so

    # Build spec
    cat > buildspec.mk <<EOF
TARGET_PRODUCT := generic
TARGET_BUILD_VARIANT := eng
TARGET_BUILD_TYPE := release
TARGET_TOOLS_PREFIX := $ANDROID_NDK_PATH/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-
EOF
}

#######################################
# Prepare dbus source code
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
android_prepare_dbus()
{
    DBUS_SOURCE=dbus-1.4.26
    wget "https://dbus.freedesktop.org/releases/dbus/${DBUS_SOURCE}.tar.gz"
    tar xvf "${DBUS_SOURCE}.tar.gz"
    cat > "${DBUS_SOURCE}/config.h" <<EOF
/* config.h.  Generated from config.h.in by configure.  */
/* config.h.in.  Generated from configure.ac by autoheader.  */

/* Define if building universal (internal helper macro) */
/* #undef AC_APPLE_UNIVERSAL_BUILD */

/* poll doesn't work on devices */
/* #undef BROKEN_POLL */

/* Directory for installing the binaries */
#define DBUS_BINDIR "/usr/bin"

/* Define to build test code into the library and binaries */
/* #undef DBUS_BUILD_TESTS */

/* Define to build X11 functionality */
#define DBUS_BUILD_X11 1

/* whether -export-dynamic was passed to libtool */
/* #undef DBUS_BUILT_R_DYNAMIC */

/* Use dnotify on Linux */
/* #undef DBUS_BUS_ENABLE_DNOTIFY_ON_LINUX */

/* Use inotify */
#define DBUS_BUS_ENABLE_INOTIFY 1

/* Use kqueue */
/* #undef DBUS_BUS_ENABLE_KQUEUE */

/* Directory to check for console ownerhip */
#define DBUS_CONSOLE_AUTH_DIR "/var/run/console/"

/* File to check for console ownerhip */
#define DBUS_CONSOLE_OWNER_FILE ""

/* Defined if we run on a cygwin API based system */
/* #undef DBUS_CYGWIN */

/* Directory for installing the DBUS daemon */
#define DBUS_DAEMONDIR "/usr/bin"

/* Name of executable */
#define DBUS_DAEMON_NAME "dbus-daemon"

/* Directory for installing DBUS data files */
#define DBUS_DATADIR "/usr/share"

/* Disable assertion checking */
#define DBUS_DISABLE_ASSERT 1

/* Disable public API sanity checking */
/* #undef DBUS_DISABLE_CHECKS */

/* Define to build test code into the library and binaries */
/* #undef DBUS_ENABLE_EMBEDDED_TESTS */

/* Use launchd autolaunch */
/* #undef DBUS_ENABLE_LAUNCHD */

/* Define to build independent test binaries (requires GLib) */
/* #undef DBUS_ENABLE_MODULAR_TESTS */

/* Build with caching of user data */
#define DBUS_ENABLE_USERDB_CACHE 1

/* Support a verbose mode */
/* #undef DBUS_ENABLE_VERBOSE_MODE */

/* Define to enable X11 auto-launch */
#define DBUS_ENABLE_X11_AUTOLAUNCH 1

/* Defined if gcov is enabled to force a rebuild due to config.h changing */
/* #undef DBUS_GCOV_ENABLED */

/* Define to printf modifier for 64 bit integer type */
#define DBUS_INT64_PRINTF_MODIFIER "ll"

/* Directory for installing the libexec binaries */
#define DBUS_LIBEXECDIR "/usr/libexec"

/* Prefix for installing DBUS */
#define DBUS_PREFIX "NONE"

/* Where per-session bus puts its sockets */
#define DBUS_SESSION_SOCKET_DIR "/tmp"

/* The default D-Bus address of the system bus */
#define DBUS_SYSTEM_BUS_DEFAULT_ADDRESS \
    "unix:path=/var/run/dbus/system_bus_socket"

/* The name of the socket the system bus listens on by default */
#define DBUS_SYSTEM_SOCKET "/var/run/dbus/system_bus_socket"

/* Full path to the launch helper test program in the builddir */
#define DBUS_TEST_LAUNCH_HELPER_BINARY \
    "/home/me/android/dbus-1.4.26/bus/dbus-daemon-launch-helper-test"

/* Where to put test sockets */
#define DBUS_TEST_SOCKET_DIR "/tmp"

/* Defined if we run on a Unix-based system */
#define DBUS_UNIX 1

/* User for running the system BUS daemon */
#define DBUS_USER "messagebus"

/* Use the gcc __sync extension */
#define DBUS_USE_SYNC 1

/* A 'va_copy' style function */
#define DBUS_VA_COPY va_copy

/* 'va_lists' cannot be copies as values */
#define DBUS_VA_COPY_AS_ARRAY 1

/* Defined if we run on a W32 API based system */
/* #undef DBUS_WIN */

/* Defined if we run on a W32 CE API based system */
/* #undef DBUS_WINCE */

/* The name of the gettext domain */
#define GETTEXT_PACKAGE "dbus-1"

/* Disable GLib public API sanity checking */
/* #undef G_DISABLE_CHECKS */

/* Have abstract socket namespace */
#define HAVE_ABSTRACT_SOCKETS 1

/* Define to 1 if you have the \`accept4' function. */
#define HAVE_ACCEPT4 1

/* Adt audit API */
/* #undef HAVE_ADT */

/* Define to 1 if you have the <byteswap.h> header file. */
#define HAVE_BYTESWAP_H 1

/* Define to 1 if you have the \`clearenv' function. */
#define HAVE_CLEARENV 1

/* Have cmsgcred structure */
/* #undef HAVE_CMSGCRED */

/* Have console owner file */
/* #undef HAVE_CONSOLE_OWNER_FILE */

/* Define to 1 if you have the <crt_externs.h> header file. */
/* #undef HAVE_CRT_EXTERNS_H */

/* Have the ddfd member of DIR */
/* #undef HAVE_DDFD */

/* Define to 1 if you have the declaration of \`LOG_PERROR', and to 0 if you
   don't. */
#define HAVE_DECL_LOG_PERROR 1

/* Define to 1 if you have the declaration of \`MSG_NOSIGNAL', and to 0 if you
   don't. */
#define HAVE_DECL_MSG_NOSIGNAL 1

/* Define to 1 if you have the <dirent.h> header file. */
#define HAVE_DIRENT_H 1

/* Have dirfd function */
#define HAVE_DIRFD 1

/* Define to 1 if you have the <dlfcn.h> header file. */
#define HAVE_DLFCN_H 1

/* Define to 1 if you have the <errno.h> header file. */
#define HAVE_ERRNO_H 1

/* Define to 1 if you have the <execinfo.h> header file. */
#define HAVE_EXECINFO_H 1

/* Define to 1 if you have the <expat.h> header file. */
#define HAVE_EXPAT_H 1

/* Define to 1 if you have the \`fpathconf' function. */
#define HAVE_FPATHCONF 1

/* Define to 1 if you have the \`getgrouplist' function. */
#define HAVE_GETGROUPLIST 1

/* Define to 1 if you have the \`getpeereid' function. */
/* #undef HAVE_GETPEEREID */

/* Define to 1 if you have the \`getpeerucred' function. */
/* #undef HAVE_GETPEERUCRED */

/* Define to 1 if you have the \`getresuid' function. */
#define HAVE_GETRESUID 1

/* Have GNU-style varargs macros */
#define HAVE_GNUC_VARARGS 1

/* Define to 1 if you have the \`inotify_init1' function. */
#define HAVE_INOTIFY_INIT1 1

/* Define to 1 if you have the <inttypes.h> header file. */
#define HAVE_INTTYPES_H 1

/* Have ISO C99 varargs macros */
#define HAVE_ISO_VARARGS 1

/* Define to 1 if you have the \`issetugid' function. */
/* #undef HAVE_ISSETUGID */

/* audit daemon SELinux support */
/* #undef HAVE_LIBAUDIT */

/* Define to 1 if you have the \`nsl' library (-lnsl). */
/* #undef HAVE_LIBNSL */

/* Define to 1 if you have the \`localeconv' function. */
#define HAVE_LOCALECONV 1

/* Define to 1 if you have the <locale.h> header file. */
#define HAVE_LOCALE_H 1

/* Define to 1 if you have the <memory.h> header file. */
#define HAVE_MEMORY_H 1

/* Define if we have CLOCK_MONOTONIC */
#define HAVE_MONOTONIC_CLOCK 1

/* Define to 1 if you have the \`nanosleep' function. */
#define HAVE_NANOSLEEP 1

/* Have non-POSIX function getpwnam_r */
/* #undef HAVE_NONPOSIX_GETPWNAM_R */

/* Define if your system needs _NSGetEnviron to set up the environment */
/* #undef HAVE_NSGETENVIRON */

/* Define to 1 if you have the \`pipe2' function. */
#define HAVE_PIPE2 1

/* Define to 1 if you have the \`poll' function. */
#define HAVE_POLL 1

/* Have POSIX function getpwnam_r */
#define HAVE_POSIX_GETPWNAM_R 1

/* SELinux support */
/* #undef HAVE_SELINUX */

/* Define to 1 if you have the \`setenv' function. */
#define HAVE_SETENV 1

/* Define to 1 if you have the \`setlocale' function. */
#define HAVE_SETLOCALE 1

/* Define to 1 if you have the \`setrlimit' function. */
#define HAVE_SETRLIMIT 1

/* Define to 1 if you have the <signal.h> header file. */
#define HAVE_SIGNAL_H 1

/* Define to 1 if you have the \`socketpair' function. */
#define HAVE_SOCKETPAIR 1

/* Have socklen_t type */
#define HAVE_SOCKLEN_T 1

/* Define to 1 if you have the <stdint.h> header file. */
#define HAVE_STDINT_H 1

/* Define to 1 if you have the <stdlib.h> header file. */
#define HAVE_STDLIB_H 1

/* Define to 1 if you have the <strings.h> header file. */
#define HAVE_STRINGS_H 1

/* Define to 1 if you have the <string.h> header file. */
#define HAVE_STRING_H 1

/* Define to 1 if you have the \`strtoll' function. */
#define HAVE_STRTOLL 1

/* Define to 1 if you have the \`strtoull' function. */
#define HAVE_STRTOULL 1

/* Define to 1 if you have the <syslog.h> header file. */
#define HAVE_SYSLOG_H 1

/* Define to 1 if you have the <sys/inotify.h> header file. */
#define HAVE_SYS_INOTIFY_H 1

/* Define to 1 if you have the <sys/resource.h> header file. */
#define HAVE_SYS_RESOURCE_H 1

/* Define to 1 if you have the <sys/stat.h> header file. */
#define HAVE_SYS_STAT_H 1

/* Define to 1 if you have the <sys/syslimits.h> header file. */
/* #undef HAVE_SYS_SYSLIMITS_H */

/* Define to 1 if you have the <sys/types.h> header file. */
#define HAVE_SYS_TYPES_H 1

/* Define to 1 if you have the <sys/uio.h> header file. */
#define HAVE_SYS_UIO_H 1

/* Define to 1 if you have the <unistd.h> header file. */
#define HAVE_UNISTD_H 1

/* Supports sending UNIX file descriptors */
#define HAVE_UNIX_FD_PASSING 1

/* Define to 1 if you have the \`unsetenv' function. */
#define HAVE_UNSETENV 1

/* Define to 1 if you have the \`usleep' function. */
#define HAVE_USLEEP 1

/* Define to 1 if you have the \`vasprintf' function. */
#define HAVE_VASPRINTF 1

/* Define to 1 if you have the \`vsnprintf' function. */
#define HAVE_VSNPRINTF 1

/* Define to 1 if you have the \`writev' function. */
#define HAVE_WRITEV 1

/* Define to 1 if you have the <ws2tcpip.h> header file. */
/* #undef HAVE_WS2TCPIP_H */

/* Define to 1 if you have the <wspiapi.h> header file. */
/* #undef HAVE_WSPIAPI_H */

/* Define to the sub-directory in which libtool stores uninstalled libraries.
 */
#define LT_OBJDIR ".libs/"

/* Define to 1 if your C compiler doesn't accept -c and -o together. */
/* #undef NO_MINUS_C_MINUS_O */

/* Name of package */
#define PACKAGE "dbus"

/* Define to the address where bug reports for this package should be sent. */
#define PACKAGE_BUGREPORT \
    "https://bugs.freedesktop.org/enter_bug.cgi?product=dbus"

/* Define to the full name of this package. */
#define PACKAGE_NAME "dbus"

/* Define to the full name and version of this package. */
#define PACKAGE_STRING "dbus 1.4.26"

/* Define to the one symbol short name of this package. */
#define PACKAGE_TARNAME "dbus"

/* Define to the home page for this package. */
#define PACKAGE_URL ""

/* Define to the version of this package. */
#define PACKAGE_VERSION "1.4.26"

/* The size of \`char', as computed by sizeof. */
#define SIZEOF_CHAR sizeof(char)

/* The size of \`int', as computed by sizeof. */
#define SIZEOF_INT sizeof(int)

/* The size of \`long', as computed by sizeof. */
#define SIZEOF_LONG sizeof(long)

/* The size of \`long long', as computed by sizeof. */
#define SIZEOF_LONG_LONG sizeof(long long)

/* The size of \`short', as computed by sizeof. */
#define SIZEOF_SHORT sizeof(short)

/* The size of \`void *', as computed by sizeof. */
#define SIZEOF_VOID_P sizeof(void*)

/* The size of \`__int64', as computed by sizeof. */
#define SIZEOF___INT64 sizeof(long long)

/* Define to 1 if you have the ANSI C header files. */
#define STDC_HEADERS 1

/* Full path to the daemon in the builddir */
#define TEST_BUS_BINARY "/home/me/android/dbus-1.4.26/bus/dbus-daemon"

/* Full path to test file test/test-exit in builddir */
#define TEST_EXIT_BINARY "/home/me/android/dbus-1.4.26/test/test-exit"

/* Full path to test file test/data/invalid-service-files in builddir */
#define TEST_INVALID_SERVICE_DIR \
    "/home/me/android/dbus-1.4.26/test/data/invalid-service-files"

/* Full path to test file test/data/invalid-service-files-system in builddir
 */
#define TEST_INVALID_SERVICE_SYSTEM_DIR \
    "/home/me/android/dbus-1.4.26/test/data/invalid-service-files-system"

/* Full path to test file test/name-test/test-privserver in builddir */
#define TEST_PRIVSERVER_BINARY \
    "/home/me/android/dbus-1.4.26/test/name-test/test-privserver"

/* Full path to test file test/test-segfault in builddir */
#define TEST_SEGFAULT_BINARY "/home/me/android/dbus-1.4.26/test/test-segfault"

/* Full path to test file test/test-service in builddir */
#define TEST_SERVICE_BINARY "/home/me/android/dbus-1.4.26/test/test-service"

/* Full path to test file test/test-shell-service in builddir */
#define TEST_SHELL_SERVICE_BINARY \
    "/home/me/android/dbus-1.4.26/test/test-shell-service"

/* Full path to test file test/test-sleep-forever in builddir */
#define TEST_SLEEP_FOREVER_BINARY \
    "/home/me/android/dbus-1.4.26/test/test-sleep-forever"

/* Full path to test file test/data/valid-service-files in builddir */
#define TEST_VALID_SERVICE_DIR \
    "/home/me/android/dbus-1.4.26/test/data/valid-service-files"

/* Full path to test file test/data/valid-service-files-system in builddir */
#define TEST_VALID_SERVICE_SYSTEM_DIR \
    "/home/me/android/dbus-1.4.26/test/data/valid-service-files-system"

/* Enable extensions on AIX 3, Interix.  */
#ifndef _ALL_SOURCE
#define _ALL_SOURCE 1
#endif
/* Enable GNU extensions on systems that have them.  */
#ifndef _GNU_SOURCE
#define _GNU_SOURCE 1
#endif
/* Enable threading extensions on Solaris.  */
#ifndef _POSIX_PTHREAD_SEMANTICS
#define _POSIX_PTHREAD_SEMANTICS 1
#endif
/* Enable extensions on HP NonStop.  */
#ifndef _TANDEM_SOURCE
#define _TANDEM_SOURCE 1
#endif
/* Enable general extensions on Solaris.  */
#ifndef __EXTENSIONS__
#define __EXTENSIONS__ 1
#endif

/* Version number of package */
#define VERSION "1.4.26"

/* Define WORDS_BIGENDIAN to 1 if your processor stores words with the most
   significant byte first (like Motorola and SPARC, unlike Intel). */
#if defined AC_APPLE_UNIVERSAL_BUILD
#if defined __BIG_ENDIAN__
#define WORDS_BIGENDIAN 1
#endif
#else
#ifndef WORDS_BIGENDIAN
/* #  undef WORDS_BIGENDIAN */
#endif
#endif

/* Use the compiler-provided endianness defines to allow universal compiling. */
#if defined(__BIG_ENDIAN__)
#define WORDS_BIGENDIAN 1
#endif

/* Define to 1 if the X Window System is missing or not being used. */
/* #undef X_DISPLAY_MISSING */

#if defined(HAVE_NSGETENVIRON) && defined(HAVE_CRT_EXTERNS_H)
#include <crt_externs.h>
#include <sys/time.h>
#define environ (*_NSGetEnviron())
#endif

/* Define to 1 if on MINIX. */
/* #undef _MINIX */

/* Define to 2 if the system does not provide POSIX.1 features except with
   this defined. */
/* #undef _POSIX_1_SOURCE */

/* Define to 1 if you need to in order for \`stat' and other things to work. */
/* #undef _POSIX_SOURCE */

/* Defined to get newer W32 CE APIs */
/* #undef _WIN32_WCE */

/* Define to \`__inline__' or \`__inline' if that's what the C compiler
   calls it, or to nothing if 'inline' is not supported under any name.  */
#ifndef __cplusplus
/* #undef inline */
#endif
EOF

    cat > "${DBUS_SOURCE}/dbus/dbus-arch-deps.h" <<EOF
/* -*- mode: C; c-file-style: "gnu" -*- */
/* dbus-arch-deps.h Header with architecture/compiler specific information, installed to libdir
 *
 * Copyright (C) 2003 Red Hat, Inc.
 *
 * Licensed under the Academic Free License version 2.0
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */
#if !defined (DBUS_INSIDE_DBUS_H) && !defined (DBUS_COMPILATION)
#error "Only <dbus/dbus.h> can be included directly, this file may disappear or change contents."
#endif

#ifndef DBUS_ARCH_DEPS_H
#define DBUS_ARCH_DEPS_H

#include <dbus/dbus-macros.h>

DBUS_BEGIN_DECLS

#if 1
#define DBUS_HAVE_INT64 1
_DBUS_GNUC_EXTENSION typedef long long dbus_int64_t;
_DBUS_GNUC_EXTENSION typedef unsigned long long dbus_uint64_t;

#define DBUS_INT64_CONSTANT(val) (_DBUS_GNUC_EXTENSION(val##LL))
#define DBUS_UINT64_CONSTANT(val) (_DBUS_GNUC_EXTENSION(val##ULL))

#else
#undef DBUS_HAVE_INT64
#undef DBUS_INT64_CONSTANT
#undef DBUS_UINT64_CONSTANT
#endif

typedef int dbus_int32_t;
typedef unsigned int dbus_uint32_t;

typedef short dbus_int16_t;
typedef unsigned short dbus_uint16_t;

/* This is not really arch-dependent, but it's not worth
 * creating an additional generated header just for this
 */
#define DBUS_MAJOR_VERSION 1
#define DBUS_MINOR_VERSION 4
#define DBUS_MICRO_VERSION 26

#define DBUS_VERSION_STRING "1.4.26"

#define DBUS_VERSION ((1 << 16) | (4 << 8) | (26))

DBUS_END_DECLS

#endif /* DBUS_ARCH_DEPS_H */
EOF
    cat > "${DBUS_SOURCE}/dbus/Android.mk" <<EOF
LOCAL_PATH:= \$(call my-dir)
include \$(CLEAR_VARS)

LOCAL_SRC_FILES := \
    dbus-address.c \
    dbus-auth.c \
    dbus-auth-script.c \
    dbus-auth-util.c \
    dbus-bus.c \
    dbus-connection.c \
    dbus-credentials.c \
    dbus-credentials-util.c \
    dbus-dataslot.c \
    dbus-errors.c \
    dbus-file.c \
    dbus-file-unix.c \
    dbus-hash.c \
    dbus-internals.c \
    dbus-keyring.c \
    dbus-list.c \
    dbus-mainloop.c \
    dbus-marshal-basic.c \
    dbus-marshal-byteswap.c \
    dbus-marshal-byteswap-util.c \
    dbus-marshal-header.c \
    dbus-marshal-recursive.c \
    dbus-marshal-recursive-util.c \
    dbus-marshal-validate.c \
    dbus-marshal-validate-util.c \
    dbus-memory.c \
    dbus-mempool.c \
    dbus-message.c \
    dbus-message-factory.c \
    dbus-message-util.c \
    dbus-misc.c \
    dbus-nonce.c \
    dbus-object-tree.c \
    dbus-pending-call.c \
    dbus-pipe.c \
    dbus-pipe-unix.c \
    dbus-resources.c \
    dbus-server.c \
    dbus-server-debug-pipe.c \
    dbus-server-launchd.c \
    dbus-server-socket.c \
    dbus-server-unix.c \
    dbus-sha.c \
    dbus-shell.c \
    dbus-signature.c \
    dbus-spawn.c \
    dbus-string.c \
    dbus-string-util.c \
    dbus-sysdeps.c \
    dbus-sysdeps-pthread.c \
    dbus-sysdeps-unix.c \
    dbus-sysdeps-util.c \
    dbus-sysdeps-util-unix.c \
    dbus-test.c \
    dbus-test-main.c \
    dbus-threads.c \
    dbus-timeout.c \
    dbus-transport.c \
    dbus-transport-socket.c \
    dbus-transport-unix.c \
    dbus-userdb.c \
    dbus-userdb-util.c \
    dbus-uuidgen.c \
    dbus-watch.c \
    sd-daemon.c \
    \$(NULL)

\$(DBUS_SOURCES:\$(LOCAL_PATH)/%=%)

LOCAL_C_INCLUDES+= \$(LOCAL_PATH)/..

LOCAL_MODULE:=libdbus

DBUS_HEADERS := \$(wildcard \$(LOCAL_PATH)/*.h)
LOCAL_COPY_HEADERS := \$(DBUS_HEADERS:\$(LOCAL_PATH)/%=%)

LOCAL_COPY_HEADERS_TO := dbus

LOCAL_CFLAGS+= \
    -DDBUS_COMPILATION \
    -DHAVE_MONOTONIC_CLOCK \
    -DDBUS_MACHINE_UUID_FILE=\"/etc/machine-id\" \
    -DDBUS_SYSTEM_CONFIG_FILE=\"/etc/dbus-1/system.conf\" \
    -DDBUS_SESSION_CONFIG_FILE=\"/etc/dbus-1/session.conf\" \
    -Wno-empty-body \
    -Wno-missing-field-initializers \
    -Wno-pointer-sign \
    -Wno-sign-compare \
    -Wno-tautological-compare \
    -Wno-type-limits \
    -Wno-unused-parameter

include \$(BUILD_SHARED_LIBRARY)
EOF
}

#######################################
# Check build with android build system
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
android_check()
{
    android_prepare_build_system
    android_prepare_dbus

    make showcommands wpanctl
    make showcommands wpantund

    test -f out/target/product/generic/system/bin/wpanctl || die
    test -f out/target/product/generic/system/bin/wpantund || die
}

set -x

[ "$BUILD_TARGET" != "toranj-test-framework" ] || {
    ./bootstrap.sh || die
    ./configure || die
    sudo make -j 8 || die
    sudo make install || die

    git clone --depth=1 --branch=master https://github.com/openthread/openthread.git

    cd openthread
    ./tests/toranj/start.sh || die
    exit 0
}

[ "$BUILD_TARGET" != android-build ] || {
    cd ..
    android_check
    exit 0
}

[ $TRAVIS_OS_NAME != linux ] || BUILD_CONFIGFLAGS="${BUILD_CONFIGFLAGS} --with-connman"

[ -e configure ] || ./bootstrap.sh || die

mkdir -p "${BUILD_MAKEPATH}" || die

cd "${BUILD_MAKEPATH}" || die

../configure ${BUILD_CONFIGFLAGS} || die

make ${BUILD_MAKEARGS} || die

cd ..
