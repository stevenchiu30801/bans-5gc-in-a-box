#!/usr/bin/python

import socket
from functools import partial

from mininet.net import Mininet
from mininet.link import Intf
from mininet.topo import Topo
from mininet.node import OVSSwitch, RemoteController
from mininet.cli import CLI
from mininet.util import quietRun
from mininet.log import setLogLevel, info, error

class MinimalTopo(Topo):

    def __init__(self):
        Topo.__init__(self)

        info( '*** Adding switch\n' )
        OVSSwitch13 = partial( OVSSwitch, protocols='OpenFlow13' )
        s1 = self.addSwitch( 's1', cls=OVSSwitch13 )

if __name__ == '__main__':
    setLogLevel( 'info' )

    topo = MinimalTopo()
    net = Mininet( topo=topo, controller=None )

    s1 = net.get( 's1' )
{{- range $i, $junk := until (.Values.numIntfs|int) -}}
{{- $intf := printf "net%d" (add $i 1) }}

    info( '*** Adding hardware interface {{ $intf }} to switch s1\n')
    _intf_1 = Intf( '{{ $intf }}', node=s1 )

    info( '*** Turning off checksum offloading on {{ $intf }}\n' )
    print quietRun( 'ethtool -K {{ $intf }} tx off rx off' )
{{- end }}

    info( '*** Adding controllers\n' )
    controllerIp = socket.gethostbyname( '{{ .Values.onosOpenflowService }}' )
    net.addController( 'onos', controller=RemoteController, ip=controllerIp, port=6653 )

    net.start()
    CLI( net )
    net.stop()
