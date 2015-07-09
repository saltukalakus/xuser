from fabric.api import *

#
# Configurations
#
master_ip = '52.28.185.233'
slave_ip = '52.28.90.184'
env.user = 'ubuntu'
env.key_filename = '/home/keys/key.pem'


local_ip_list =[]
env.hosts = [master_ip, slave_ip]

@parallel
@with_settings(warn_only=True)
def git_checkout():
    sudo('rm -Rf xuser')
    run('git clone https://github.com/saltukalakus/xuser')

@parallel
@with_settings(warn_only=True)
def git_pull():
    with cd('/home/ubuntu/xuser'):
        run('git pull')

@hosts(master_ip)
@with_settings(warn_only=True)
def install_master(secret, lmaster_ip, lslave_ip):
    with cd('/home/ubuntu/xuser/infra/duo'):
        execute = './install_master.sh' + ' ' + secret + ' ' + lmaster_ip + ' ' + lslave_ip
        sudo(execute, user="root")

@hosts(slave_ip)
@with_settings(warn_only=True)
def install_slave(secret, lmaster_ip, lslave_ip):
    with cd('/home/ubuntu/xuser/infra/duo'):
        execute = './install_slave.sh' + ' ' + secret + ' ' + lmaster_ip + ' ' + lslave_ip
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

@with_settings(warn_only=True)
@runs_once
def generate_ssl_key():
    with lcd('../ssl'):
        local('./ssl-key-gen.sh')

@parallel
@with_settings(warn_only=True)
def copy_ssl_key():
    put('../ssl/site.pem', '/etc/ssl/private/site.pem', use_sudo=True)

@parallel
@with_settings(warn_only=True)
def reboot_all():
    reboot(wait=0)

@parallel
@with_settings(warn_only=True)
def git_install():
    sudo('apt-get install -y git', user="root")

