from fabric.api import *
 
env.hosts = ['52.28.149.188']
env.user = 'ubuntu'
env.key_filename = '/home/keys/key.pem'
 
def local_uname():
    local('uname -a')
 
def remote_uname():
    run('uname -a')

def taskA():
    run('ls')