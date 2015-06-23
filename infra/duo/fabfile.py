from fabric.api import *

local_ip_list =[]
env.hosts = ['52.28.150.155', '52.28.154.136']
env.user = 'ubuntu'
env.key_filename = '/home/keys/key.pem'

@with_settings(warn_only=True)
def git_checkout():
    run('git clone https://github.com/saltukalakus/xuser')

@with_settings(warn_only=True)
def git_pull():
    with cd('/home/ubuntu/xuser'):
        run('git pull')

@hosts('ubuntu@52.28.150.155')
@with_settings(warn_only=True)
def install_master(ip_list):
    with settings(sudo_user='root'):
        with cd('/home/ubuntu/xuser/infra/duo'):
            execute = './install_master.sh' + ' ' + ip_list[0] + ' ' + ip_list[1]
            sudo(execute, user="root")

@hosts('ubuntu@52.28.154.136')
@with_settings(warn_only=True)
def install_slave(ip_list):
    with cd('/home/ubuntu/xuser/infra/duo'):
        execute = './install_slave.sh' + ' ' + ip_list[0] + ' ' + ip_list[1]
        sudo(execute, user="root")

@with_settings(warn_only=True)
def install():
    global local_ip_list
    if len(local_ip_list) == len(env.hosts):
        local_ip_list = []
        print "Clean local ip list. There is something wrong"

    result = run("ifconfig eth0 | grep inet | awk '{print $2}' | cut -d':' -f2")
    local_ip_list.append(result)

    if len(local_ip_list) == len(env.hosts):
        for i in local_ip_list:
            print ("%s" % i)
        install_slave(local_ip_list)
        install_master(local_ip_list)