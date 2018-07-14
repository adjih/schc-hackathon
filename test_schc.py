#! /usr/bin/env micropython

import sys
sys.path.append("schc-test-cedric")
sys.path.append("schc-test")

from debug_print import *
from schc_param import *
import schc_fragment_sender as sfs
from debug_print import *
from schc_fragment_ruledb import schc_fragment_ruledb

impl_name = sys.implementation.name

print("Running schc-test on micropython-on-unix (%s)" % impl_name)

# ./test-frag-client-udp.py 127.0.0.1 9999 --context-file="example-rule/context-001.json" --rule-file="example-rule/fragment-rule-002.json" --dtag=3 -I test/message.txt --l2-size=6 -dd

#---------------------------------------------------------------------------
# copied from schc-test/test-frag-client-udp.py (and modified)
        
def schc_sender(msg):
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
            #XXX: s.sendto(tx_obj.packet, server)
            print("SEND:", tx_obj.packet)
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

        #XXX:
        #time.sleep(opt.interval)
        print("time.sleep")
        

#---------------------------------------------------------------------------
# Options

class empty_class:
    pass
opt = empty_class()

opt.context_file = "schc-test/example-rule/context-001.json"
opt.rule_file = "schc-test/example-rule/fragment-rule-002.json"
opt.l2_size = 6
opt.dtag = 2
opt.func_packet_loss = None



#--------------------------------------------------

debug_set_level(2)

frdb = schc_fragment_ruledb()
cid = frdb.load_context_json_file(opt.context_file)
rid = frdb.load_json_file(cid, opt.rule_file)
frr = frdb.get_runtime_rule(cid, rid)

packet_str = 10*"1234567890"
if impl_name == "micropython":
    packet = bytearray(packet_str)
else: packet = bytearray(packet_str, "utf-8")

schc_sender(packet)

#---------------------------------------------------------------------------
