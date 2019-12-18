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

    print quietRun( 'service openvswitch-switch start' )

    topo = MinimalTopo()
    net = Mininet( topo=topo, controller=None )

    info( '*** Adding hardware interface to switch s1\n')
    s1 = net.get( 's1' )
    _intf_1 = Intf( 'net1', node=s1 )
    _intf_2 = Intf( 'net2', node=s1 )

    info( '*** Turning off checksum offloading\n' )
    print quietRun( 'ethtool -K net1 tx off rx off' )
    print quietRun( 'ethtool -K net2 tx off rx off' )

    info( '*** Adding controllers\n' )
    controllerIp = socket.gethostbyname( 'onos-openflow-service.default.svc.cluster.local' )
    net.addController( 'onos', controller=RemoteController, ip=controllerIp, port=6653 )

    net.start()
    CLI( net )
    net.stop()
