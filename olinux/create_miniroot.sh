#/bin/sh

########################
# Miniroot compilation #
########################

set -e
set -x

show_usage() {
cat <<EOF
# NAME

  $(basename $0) -- Script to build sunxi kernel and boot files

EOF
exit 1
}

#while getopts ":ot:" opt; do
#  case $opt in
#    o)
#      offline=$OPTARG
#      ;;
#    t)
#      olinux=$OPTARG
#      ;;
#    \?)
#      show_usage
#      ;;
#  esac
#done

clone_or_pull (){
  project=$1
  repo=$2
  name=$(echo $project |  sed 's/.git$//')
  if [ "$offline" ] ; then
    cd /olinux/$name/ && make clean KERNEL_MODULES=faitchieraveccettevarible
    return 0
  fi
  if [ -d /olinux/$name/ ] ; then
    cd /olinux/$name/ && make clean KERNEL_MODULES=faitchieraveccettevarible \
 && git pull --depth 1
  else
    git clone --depth 1 $repo/$project /olinux/$name/
  fi
}

# Miniroot  
clone_or_pull miniroot.git https://github.com/bleuchtang
mkdir -p /olinux/miniroot/initramfs/etc/dropbear/
dropbearkey -t dss -f \
 /olinux/miniroot/initramfs/etc/dropbear/dropbear_dss_host_key
dropbearkey -t rsa -f \
 /olinux/miniroot/initramfs/etc/dropbear/dropbear_rsa_host_key
cd /olinux/miniroot && git fetch && git checkout dropbear
cd /olinux/miniroot && \
 make KERNEL_MODULES=/olinux/sunxi/linux-sunxi/out/lib/modules/3.4.103+/
