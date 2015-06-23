from fabric.api import *

master_ip = '52.28.150.155'
slave_ip = '52.28.154.136'
local_ip_list =[]
env.hosts = [master_ip, slave_ip]
env.user = 'ubuntu'
env.key_filename = '/home/keys/key.pem'

@with_settings(warn_only=True)
def git_checkout():
    sudo('rm -Rf xuser')
    run('git clone https://github.com/saltukalakus/xuser')

@with_settings(warn_only=True)
def git_pull():
    with cd('/home/ubuntu/xuser'):
        run('git pull')

@hosts(master_ip)
@with_settings(warn_only=True)
def install_master(lmaster_ip, lslave_ip):
    with settings(sudo_user='root'):
        with cd('/home/ubuntu/xuser/infra/duo'):
            execute = './install_master.sh' + ' ' + lmaster_ip + ' ' + lslave_ip
            sudo(execute, user="root")

@hosts(slave_ip)
@with_settings(warn_only=True)
def install_slave(lmaster_ip, lslave_ip):
    with cd('/home/ubuntu/xuser/infra/duo'):
        execute = './install_slave.sh' + ' ' + lmaster_ip + ' ' + lslave_ip
        sudo(execute, user="root")

@with_settings(warn_only=True)
def get_local_ip():
    global local_ip_list
    if len(local_ip_list) == len(env.hosts):
        local_ip_list = []
        print "Clean local ip list. There is something wrong"

    result = run("ifconfig eth0 | grep inet | awk '{print $2}' | cut -d':' -f2")
    local_ip_list.append(result)

    if len(local_ip_list) == len(env.hosts):
        for i in local_ip_list:
            print ("%s" % i)