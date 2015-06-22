from fabric.api import *
 
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
def install_master():
    with settings(sudo_user='root'):
        with cd('/home/ubuntu/xuser/infra/duo'):
            sudo('./install_master.sh', user="root")

@hosts('ubuntu@52.28.154.136')
@with_settings(warn_only=True)
def install_slave():
    with cd('/home/ubuntu/xuser/infra/duo'):
        sudo('./install_slave.sh', user="root")

@with_settings(warn_only=True)
def get_local_ip():
    run("ifconfig eth0 | grep inet | awk '{print $2}' | cut -d':' -f2")