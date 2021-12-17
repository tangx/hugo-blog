#!/bin/bash
#
#
# lvs_nat_rs.sh
#
# nat 模式下， rs 只需要把网关设置为 LB 即可
#

lb_intip=192.168.56.206

route del default
route add default $lb_intip

