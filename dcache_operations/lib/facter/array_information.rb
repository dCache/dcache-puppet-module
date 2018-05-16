require 'json'

Facter.add(:array_disks) do
  confine :kernel => "Linux"
  confine :hostgroup_1 => /^(dcache|dot)$/
  confine :hostgroup_1 => "pool"
  setcode do
    if !(Facter.value(:array_type).to_s.empty?) then
      begin
        JSON.parse(File.read('/var/tmp/sm-getprofile.tmp'))['array_disks']
      rescue
        ""
      end
    end
  end
end

Facter.add(:array_name) do
  confine :kernel => "Linux"
  confine :hostgroup_1 => /^(dcache|dot)$/
  confine :hostgroup_1 => "pool"
  setcode do
    if !(Facter.value(:array_type).to_s.empty?) then
      begin
        JSON.parse(File.read('/var/tmp/sm-getprofile.tmp'))['array_name']
      rescue
        ""
      end
    end
  end
end

Facter.add(:array_nvsram_version) do
  confine :kernel => "Linux"
  confine :hostgroup_1 => /^(dcache|dot)$/
  confine :hostgroup_1 => "pool"
  setcode do
    if !(Facter.value(:array_type).to_s.empty?) then
      begin
        JSON.parse(File.read('/var/tmp/sm-getprofile.tmp'))['array_nvsram_version']
      rescue
        ""
      end
    end
  end
end

Facter.add(:array_package_version) do
  confine :kernel => "Linux"
  confine :hostgroup_1 => /^(dcache|dot)$/
  confine :hostgroup_1 => "pool"
  setcode do
    if !(Facter.value(:array_type).to_s.empty?) then
      begin
        JSON.parse(File.read('/var/tmp/sm-getprofile.tmp'))['array_package_version']
      rescue
        ""
      end
    end
  end
end
