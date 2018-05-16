Facter.add(:blockdevices_array) do
  setcode do
   blockdevices = Facter::Core::Execution.execute("cat /proc/mounts | grep dcache | awk -F ' ' '{print $1}' | xargs | sed -e 's/ /,/g'")
   blockdevices.split(',')
  end
end

Facter.add(:pools) do
  confine :kernel => "Linux"
  confine :hostgroup_0 => "dot"
  confine :hostgroup_1 => "pool"
 
  setcode do
    pools = {}

    Facter.value(:blockdevices_array).each do |device|
      lsblk_command = 'lsblk -b -n -o LABEL,MOUNTPOINT,SIZE ' + device + '  | grep dcache'
      pool = {}
      pool_info = Facter::Core::Execution.execute(lsblk_command)
      pool_info = pool_info.split(' ')
      if pool_info[0]
        pool['MOUNTPOINT'] = pool_info[1]
        pool['SIZE'] = pool_info[2]
        pools[pool_info[0]] = pool
     end
    end
    pools
  end
end

Facter.add(:n_pools) do
  confine :kernel => "Linux"
  confine :hostgroup_0 => "dot"
  confine :hostgroup_1 => "pool"
 
  setcode do
    n_pools  = Facter.value(:pools).size
  end
end
