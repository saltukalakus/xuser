from fabric.api import *
 
env.hosts = ['52.28.149.188']
env.user = 'ubuntu'
env.key_filename = '/home/keys/key.pem'

@with_settings(warn_only=True)
def remote_git_checkout():
    run('cd /home/ubuntu')
    run('git clone https://github.com/saltukalakus/xuser')

@with_settings(warn_only=True)
def remote_git_pull():
    with cd('/home/ubuntu/xuser'):
        run('pwd')
        run('git pull')
    run('pwd')

@with_settings(warn_only=True)
def remote_install():
    with cd('/home/ubuntu/xuser/infra/duo'):
        run('sudo su')
        run('whoami')
        run ('./install_master.sh')

