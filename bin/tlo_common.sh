environment=/home/bmb/tlo/flash-vm

source "$environment/coords.sh"

mkdir -p /tmp/tlo_working
pushd /tmp/tlo_working
cp "$environment/images"/* .

