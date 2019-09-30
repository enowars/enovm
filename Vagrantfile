# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
    config.vm.box = "debian/buster64"
    config.vm.boot_timeout = 600
    config.vm.box_check_update = false
    min_teamid = 1
    max_teamid = 2
    teamids = (min_teamid..max_teamid)

    # Ansible Variables
    host_vars = {
        "gameservers" => ["gameserver"]
    }
    extra_vars = {
        "teams" => {
            "min" => min_teamid,
            "max" => max_teamid,
            "range" => teamids.to_a,
        }
    }
    teamids.each do |i| 
        host_vars["vulnbox#{i}"] = {
            "id" =>  i
        }
    end

    # Gameserver
    config.vm.define "gameserver" do |gameserver|
        gameserver.vm.hostname = "gameserver"
        gameserver.vm.provider "libvirt" do |v|
            v.memory = 4096
            v.cpus = 4
        end
        gameserver.vm.provision :ansible do |ansible|
            # Disable default limit to connect to all the machines
            ansible.limit = "all"
            ansible.host_vars = host_vars
            ansible.extra_vars = extra_vars
            ansible.playbook = "ansible/bambiserver.yml"
            #ansible.ask_vault_pass = true
        end
    end

    # Vulnboxes
    teamids.each do |i|
        config.vm.define "vulnbox#{i}" do |node|
            node.vm.hostname = "vulnbox#{i}"
            node.vm.provider "libvirt" do |v|
                v.memory = 2048
                v.cpus = 2
                v.management_network_mode = "open"
            end
            if i == max_teamid
                node.vm.provision :ansible do |ansible|
                    # Disable default limit to connect to all the machines
                    ansible.limit = "all"
                    ansible.host_vars = host_vars
                    ansible.extra_vars = extra_vars
                    ansible.playbook = "ansible/bambivulnbox.yml"
                    #ansible.ask_vault_pass = true
                end
            end
        end
    end
end
