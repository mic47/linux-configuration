#!/usr/bin/python
import argparse
import json
import os
import random
import re
import sys
import socket

home_directory = os.path.expanduser("~")

hostnames = {
   'shall-we-begin': ['mic@shall-we-begin.local', 'mic@ksp.sk:47022', 'tor:mic@mic47cake2dfg5qb.onion'],
   'ksp.sk': ['mic@ksp.sk'],
   'compbio.fmph.uniba.sk': ['mic@compbio.fmph.uniba.sk'],
   'panda-cub': ['mic@panda-cub.local'],
}

parameters = {
    '.*': ['-CtX']
}

tunnels = {}

class QuitWithExitcode(Exception):
    def __init__(self, exit_code, msg=None, exception=None):
        self.exit_code = exit_code
        self.exception = exception
        self.msg = msg

def parse_hostname(candidate):
    if type(candidate) == list:
        candidate = random.choice(candidate)
    x = candidate.split(':')
    protocol = 'ssh'
    if x[0] in ['ssh', 'tor']:
        protocol = x[0]
        x = x[1:]
    if len(x) > 2:
        raise QuitWithExitcode(1, 'Unable to parse hostname: ' + candidate)
    server = x[0]
    port = 22
    if len(x) > 1:
        try:
            port = int(x[1])
        except ValueError:
            raise QuitWithExitcode(1, 'Port number must be string: ' + candidate)
    return (protocol, server, port)

def get_tor_first(collection):
    a = filter(lambda x: x[0] == 'tor', collection)
    b = filter(lambda x: x[0] != 'tor', collection)
    a.extend(b)
    return a

def too_many_servers(server, matches):
    print '"{}" matches following hosts:'.format(server);
    print '\n'.join(matches)
    raise QuitWithExitcode(1, 'Too many hostname matches.');

def get_candidate(candidates):
    for (protocol, hostname, port) in candidates:
        try:
            if protocol != 'tor':
                socket.gethostbyname(hostname.split('@')[-1])
            else:
                # TODO: resolve 
                pass
        except:
            continue
        return (protocol, hostname, port)
    raise QuitWithExitcode(1, 'None of the hostnames are available: ' + ' '.join(map(lambda x: ':'.join(map(str,x)), candidates)))

def regexp_fil(x, name):
    if name == None:
        return False
    r, param = x
    return re.match(r, name) != None

def main(args):
    global hostnames
    global tunnels
    global parameters
    servers = []
    for key in hostnames:
        if key.startswith(args.server):
            servers.append(key)
    if len(servers) > 1:
        servers = too_many_servers(args.server, servers)
    assert(len(servers) <= 1)
    force_tor = args.force_tor
   
    if len(servers) == 1:
        server = servers[0]
        candidate_hostnames = hostnames[server]
    else:
        server = None
        candidate_hostnames = [args.server]
    candidate_hostnames = list(map(parse_hostname, candidate_hostnames))
    if force_tor and not args.nohs:
        candidate_hostnames = get_tor_first(candidate_hostnames)
    protocol, hostname, port = get_candidate(candidate_hostnames) 
    tor_command = ''
    if protocol == 'tor' or force_tor:
        tor_command = 'torsocks '
    cmd_param = filter(lambda x: regexp_fil(x, server), tunnels.iteritems())
    cmd_param.extend(filter(lambda x: regexp_fil(x, server), parameters.iteritems()))
    
    shell = "'~/bin/tmux_list.sh'"
    if args.session != '':
        shell = 'tmux new-session -A -s "{}"'.format(args.session)
    
    cmd_param = map(lambda x: ' '.join(x[1]), cmd_param)
    command = '{tor}ssh {param} -p {port} {hostname} {shell}'.format(
        tor = tor_command,
        param = ' '.join(cmd_param),
        port = str(port),
        hostname = hostname,
        shell = shell,
    )
    print "Running"
    print ' ', command
    os.system(command)
    
if __name__ == "__main__":
    try:
        with open(home_directory + '/.tsh') as f:
            config = json.load(f)
            try: 
                hostnames.update(config['hostnames'])
            except Exception as e:
                sys.stderr.write(e.message)
                pass
            try:
                tunnels.update(config['tunnels'])
            except Exception as e:
                sys.stderr.write(e.message)
                pass
            try:
                parameters.update(config['parameters'])
            except Exception as e:
                sys.stderr.write(e.message)
                pass
    except Exception as e:
        pass
    parser = argparse.ArgumentParser(description='Connect to ssh server with tmux')
    parser.add_argument('server', type=str,
                   help='Where you want to connect')
    parser.add_argument('session', type=str, nargs='*', 
            help='Session name')
    parser.add_argument('-t', '--force_tor', default=False,
            action='store_true', help='for ssh over tor (will prefer hidden services, unless --nohs flag is present)?',
    )
    parser.add_argument('--nohs' , default=False, action='store_true', help='Do not prefer hidden services')
    sa = sys.argv
    if sa[0].endswith('bin/tsh.py'):
        sa = sa[1:] 
    args = parser.parse_args(sa)
    args.session = ' '.join(args.session)
    try:
        main(args)
    except QuitWithExitcode as e:
        if e.msg:
            sys.stderr.write(e.msg)
            sys.stderr.write('\n')
        if e.exception:
            sys.stderr.write(e.exception.message)
            sys.stderr.write('\n')
        exit(e.exit_code)

