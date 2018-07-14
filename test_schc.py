#! /usr/bin/env micropython

import sys
sys.path.append("schc-test-cedric")
sys.path.append("schc-test")

from debug_print import *
from schc_param import *
import schc_fragment_sender as sfs
from debug_print import *
from schc_fragment_ruledb import schc_fragment_ruledb
import schc_fragment_receiver as sfr
try: import socket
except: import usocket as socket
try: import time
except: import utime as time
#import pyssched as ps
import copied_pyssched as ps

# ./test-frag-client-udp.py 127.0.0.1 9999 --context-file="example-rule/context-001.json" --rule-file="example-rule/fragment-rule-002.json" --dtag=3 -I test/message.txt --l2-size=6 -dd

RECV_UDP_ADDRESS = "127.0.0.1"
RECV_UDP_PORT = 9900

SEND_UDP_ADDRESS = "127.0.0.1"
SEND_UDP_PORT = 9999

#---------------------------------------------------------------------------

def get_sockaddr(address, port):
    return socket.getaddrinfo(address, port)[0][-1]

#---------------------------------------------------------------------------
# copied from schc-test/test-frag-client-udp.py (and modified)
        
def schc_fragmenter_send(msg, s, opt):
    """Send message on socket s, fragmenting it as necessary"""
    assert type(msg) == bytearray # avoid compatibility problems
    debug_print(2, "message:", msg)
    # XXX assuming that the rule_id is not changed in a session.
    
    # check if the L2 size is enough to put the message.
    if opt.l2_size >= len(msg):
        debug_print(1, "no need to fragment this message.")
        return
    
    # prepare fragmenting
    factory = sfs.fragment_factory(frr, logger=debug_print)
    factory.setbuf(msg, dtag=opt.dtag)
    
    # main loop
    debug_print(1, "L2 payload size: %s" % opt.l2_size)
    
    global n_packet
    n_packet = 0
    
    while True:
    
        # CONT: send it and get next fragment.
        # WAIT_ACK: send it and wait for the ack.
        # DONE: dont need to send it.
        # ERROR: error happened.
        ret, tx_obj = factory.next_fragment(opt.l2_size)
        n_packet += 1
    
        # error!
        if ret == sfs.STATE.FAIL:
            raise AssertionError("something wrong in fragmentation.")
        elif ret == sfs.STATE.DONE:
            debug_print(1, "done.")
            break
            # end of the main loop
    
        if opt.func_packet_loss and opt.func_packet_loss() == True:
            debug_print(1, "packet dropped.")
        else:
            print("SEND:", tx_obj.packet)
            #address = socket.getaddrinfo('127.0.0.1', UDP_PORT)[0][-1]
            address = get_sockaddr(RECV_UDP_ADDRESS, RECV_UDP_PORT)
            s.sendto(tx_obj.packet, address)
            debug_print(1, "sent  :", tx_obj.dump())
            debug_print(2, "hex   :", tx_obj.full_dump())
    
        if factory.R.mode != SCHC_MODE.NO_ACK and ret != sfs.STATE.CONT:
            # WAIT_ACK
            # a part of or whole fragments have been sent and wait for the ack.
            debug_print(1, "waiting an ack.", factory.state.pprint())
            try:
                rx_data, peer = s.recvfrom(DEFAULT_RECV_BUFSIZE)
                debug_print(1, "message from:", peer)
                #
                ret, rx_obj = factory.parse_ack(rx_data, peer)
                debug_print(1, "parsed:", rx_obj.dump())
                debug_print(2, "hex   :", rx_obj.full_dump())
                #
                if ret == sfs.STATE.DONE:
                    # finish if the ack against all1 is received.
                    debug_print(1, "done.")
                    break
                    # end of the main loop
    
            except Exception as e:
                if "timeout" in repr(e):
                    debug_print(1, "timed out to wait for the ack.")
                else:
                    debug_print(1, "Exception: [%s]" % repr(e))
                    debug_print(0, traceback.format_exc())

        time.sleep(opt.interval)

#---------------------------------------------------------------------------
# copied from schc-test/test-frag-server-udp.py (and modified)

def schc_fragmenter_recv(s, sched, factory, opt):
    
    while True:

        # execute scheduler and get the number for timeout..
        timer = sched.execute()
        if not timer:
            s.setblocking(True)
        else:
            print("XXX: not setting timeout")
            #s.settimeout(timer)
            s.setblocking(True)

        # find a message for which a sender has sent all-1.
        for i in factory.dig():
            debug_print(1, "defragmented message: [%s]" % i)

        try:
            #
            # if timeout happens recvfrom() here, go to exception.
            #
            rx_data, peer = s.recvfrom(DEFAULT_RECV_BUFSIZE)
            debug_print(1, "message from:", peer)
            #
            # XXX here, should find a context for the peer.
            #
            ret, rx_obj, tx_obj = factory.defrag(cid, rx_data)
            debug_print(1, "parsed:", rx_obj.dump())
            debug_print(2, "hex   :", rx_obj.full_dump())
            #
            if ret in [sfr.STATE.CONT, sfr.STATE.CONT_ALL0, sfr.STATE.CONT_ALL1]:
                pass
            elif ret == sfr.STATE.ABORT:
                debug_print(1, "abort.")
                debug_print(1, "sent  :", tx_obj.dump())
                s.sendto(tx_obj.packet, peer)
            elif ret in [sfr.STATE.ALL0_OK, sfr.STATE.ALL0_NG]:
                if tx_obj:
                    debug_print(1, "sening ack for all-0.", tx_obj.dump())
                    debug_print(2, "packet:", tx_obj.full_dump())
                    s.sendto(tx_obj.packet, peer)
            elif ret in [sfr.STATE.ALL1_OK, sfr.STATE.ALL1_NG]:
                if tx_obj:
                    debug_print(1, "sending ack for all-1.", tx_obj.dump())
                    debug_print(2, "packet:", tx_obj.full_dump())
                    s.sendto(tx_obj.packet, peer)
                if ret == sfr.STATE.ALL1_OK:
                    debug_print(1, "finished")
                    debug_print(1, "waiting for something in %d seconds." %
                            opt.timer_t3)
            elif ret == sfr.STATE.DONE:
                debug_print(1, "finished.")
            elif ret in [sfr.STATE.WIN_DONE]:
                # ignore it
                pass
            else:
                debug_print(1, ret, ":", tx_obj)

        except Exception as e:
            if "timeout" in repr(e):
                debug_print(1, "timed out:", repr(e))
            else:
                debug_print(1, "Exception: [%s]" % repr(e))
                debug_print(0, traceback.format_exc())

#---------------------------------------------------------------------------

def do_fragmenter_send(packet_str, opt):
    global frr, impl_name
    frdb = schc_fragment_ruledb()
    cid = frdb.load_context_json_file(opt.context_file)
    rid = frdb.load_json_file(cid, opt.rule_file)
    frr = frdb.get_runtime_rule(cid, rid)

    if impl_name == "micropython":
        packet = bytearray(packet_str)
    else: packet = bytearray(packet_str, "utf-8")

    sd = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    address = get_sockaddr(SEND_UDP_ADDRESS, SEND_UDP_PORT)
    sd.bind(address)    
    schc_fragmenter_send(packet, sd, opt)


def do_fragmenter_recv(opt):
    global cid
    sched = ps.ssched()
    factory = sfr.defragment_factory(scheduler=sched,
                                     timer_t1=opt.timer_t1,
                                     timer_t3=opt.timer_t3,
                                     timer_t4=opt.timer_t4,
                                     timer_t5=opt.timer_t5,
                                     logger=debug_print)
    cid = factory.set_context(opt.context_file)
    factory.set_rule(cid, [opt.rule_file])
    server = (RECV_UDP_ADDRESS, RECV_UDP_PORT)
    debug_print(1, "server:", server)
    sd = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    address = get_sockaddr(*server)
    sd.bind(address)

    schc_fragmenter_recv(sd, sched, factory, opt)

#---------------------------------------------------------------------------
# Options

class empty_class:
    pass

#--------------------------------------------------

opt = empty_class()

# For sender
opt.context_file = "schc-test/example-rule/context-001.json"
opt.rule_file = "schc-test/example-rule/fragment-rule-002.json"
opt.l2_size = 6
opt.dtag = 2
opt.func_packet_loss = None
opt.interval = 0.1

# For receiver
opt.timer_t1 = DEFAULT_TIMER_T1
opt.timer_t2 = DEFAULT_TIMER_T2
opt.timer_t3 = DEFAULT_TIMER_T3
opt.timer_t4 = DEFAULT_TIMER_T4
opt.timer_t5 = DEFAULT_TIMER_T5

impl_name = sys.implementation.name
print("Python implementation: %s" % sys.implementation)

debug_set_level(2)

if "send" in sys.argv:
    packet = "0123456789" * 10
    do_fragmenter_send(packet, opt)
elif "recv" in sys.argv:
    do_fragmenter_recv(opt)
else: print("Not doing anything, please pass argument 'send' or 'recv'")

#---------------------------------------------------------------------------
