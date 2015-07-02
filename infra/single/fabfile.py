from fabric.api import *
 
env.hosts = ['52.28.150.155']
env.user = 'ubuntu'
env.key_filename = '/home/keys/key.pem'

@with_settings(warn_only=True)
def git_checkout():
    run('git clone https://github.com/saltukalakus/xuser')

@with_settings(warn_only=True)
def git_pull():
    with cd('/home/ubuntu/xuser'):
        run('git pull')

@with_settings(warn_only=True)
def install(secret):
    with settings(sudo_user='root'):
        with cd('/home/ubuntu/xuser/infra/single'):
            execute = './install_slave.sh' + ' ' + secret
            sudo(execute, user="root")
