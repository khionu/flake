#!/run/current-system/sw/bin/nu

let disk_path = "/dev/disk/by-path/pci-0000:47:00.0-nvme-1"
let disk_uuid = random uuid
let boot_uuid = random uuid
let data_uuid = random uuid

def part [uuid: string] {
  $"/dev/disk/by-partuuid/($uuid)"
}

def sgdisk [args: list] {
  run-external ${pkgs.gptfdisk}/bin/sgdisk ...$args
}

def cryptsetup [args: list] {
  run-external ${pkgs.cryptsetup}/bin/cryptsetup ...$args
}

def cryptenroll [args: list] {
  run-external ${pkgs.systemd}/bin/systemd-cryptenroll ...$args
}

def mk_dataset [name: string, backup: bool = true] {
  mut args = ["create" "-p" "-o mountpoint=legacy"]
  if !backup {
    $args = ($args | append "-o com.sun:auto-snapshot=false")
  }
  $args = ($args | append "zroot/($name)")

  run-external zfs ...$args
}

sgdisk -Z $disk_path -g $disk_path -U $disk_uuid \
  -n 0:0:+1G -t 0:EF00 -c 0:boot      -u $boot_uuid
  -n 0:0:0   -t 0:8309 -c 0:encrypted -u $data_uuid

cryptsetup luksFormat $"(part $data_uuid)"
cryptsetup open $"(part $data_uuid)" nixos
systemd-cryptenroll $"(part $data_uuid)" --fido2-device=auto --fido2-with-client-pin=true
input "Press enter after swapping hardware keys"
systemd-cryptenroll $"(part $data_uuid)" --fido2-device=auto --fido2-with-client-pin=true

zpool create -f \
  -o ashift=12 \
  -O acltype=posixacl \
  -O atime=off \
  -O relatime=off \
  -O xattr=sa \
  -O dnodesize=legacy \
  -O normalization=formD \
  -O mountpoint=none \
  -O canmount=off \
  -O devices=off \
  -O compression=zstd \
  -R /mnt \
  zroot /dev/mapper/nixos

zfs create -V 32G 
  -b 4096 \
  -o compression=zle \
  -o logbias=throughput \
  -o sync=always \
  -o primarycache=metadata \
  -o secondarycache=none \
  -o com.sun:auto-snapshot=false \
  zroot/SWAP

mk_dataset "EPHEM" false
mk_dataset "EPHEM/ROOT"
mk_dataset "PERSIST/etc/nix"
mk_dataset "PERSIST/etc/nixos"
mk_dataset "PERSIST/home"
mk_dataset "PERSIST/nix"
mk_dataset "PERSIST/var"

zfs snapshot -R zroot@__blank

mount -t zfs zroot/EPHEM/ROOT /mnt

for p in ["/mnt/boot" "/mnt/etc/nix" "/mnt/etc/nixos" "/mnt/home" "/mnt/nix" "/mnt/var"] {
  mkdir -p $p
}

mount $(part $boot_uuid) /mnt/boot
mount -t zfs zroot/PERSIST/etc/nix /mnt/etc/nix
mount -t zfs zroot/PERSIST/etc/nixos /mnt/etc/nixos
mount -t zfs zroot/PERSIST/home /mnt/home
mount -t zfs zroot/PERSIST/nix /mnt/nix
mount -t zfs zroot/PERSIST/var /mnt/var
