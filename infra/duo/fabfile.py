from fabric.api import *
 
env.hosts = ['52.28.149.188']
env.user = 'ubuntu'
env.key_filename = '/home/keys/key.pem'
 
def remote_git_checkout():
    env.warn_only = True
    run('cd /home/ubuntu')
    run('git clone https://github.com/saltukalakus/xuser')

def remote_git_pull():
    env.warn_only = True
    run('cd /home/ubuntu/xuser')
    run('git pull')

def remote_install():
    env.warn_only = True
    run('cd /home/ubuntu/xuser/infra/duo')
    run ('./install_master.sh')
