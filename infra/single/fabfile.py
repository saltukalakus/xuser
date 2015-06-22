from fabric.api import *
 
env.hosts = ['52.28.150.155']
env.user = 'ubuntu'
env.key_filename = '/home/keys/key.pem'

@with_settings(warn_only=True)
def git_checkout():
    run('cd /home/ubuntu')
    run('git clone https://github.com/saltukalakus/xuser')

@with_settings(warn_only=True)
def git_pull():
    with cd('/home/ubuntu/xuser'):
        run('pwd')
        run('git pull')
    run('pwd')

@with_settings(warn_only=True)
def install():
    with settings(sudo_user='root'):
        with cd('/home/ubuntu/xuser/infra/single'):
            sudo('./install.sh', user="root")
