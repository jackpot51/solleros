;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;EXAMPLES;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;THIS IS AN EXAMPLE OF A FRAME SENDING TCP/IP DATA
;;SEE BELOW FOR MORE FRAME/SEGMENT TYPES

;;0000  00 0f b3 42 6e 00 00 1c df 0c 38 e5 08 00 45 00   ...Bn.....8...E.
;;0010  00 30 1c 81 40 00 80 06 5c f0 c0 a8 00 05 c0 a8   .0..@...\.......
;;0020  00 01 08 e9 00 50 24 6e 0e 56 00 00 00 00 70 02   .....P$n.V....p.
;;0030  40 00 85 cb 00 00 02 04 05 b4 01 01 04 02         @.............

		times 7 db 10101010b	;;preamble used by NIC

		db 10101011b		;;delimiter used by NIC


ethernetIIframe:	;;64 to 1500 bytes
	

	ethernetIIheader:

		db 0x00,0x0F,0xB3,0x42,0x6E,0x00	;;48 bits-destination mac address = 00:0F:B3:42:6E:00

		db 0x00,0x1C,0xDF,0x0C,0x38,0xE5	;;48 bits-source mac address = 00:1C:DF:0C:38:E5

		db 0x08,0x00				;;16 bits-type of data = 0x0800
								;;0x0800 IPv4
	ethernetIIheaderend:					;;0x0806 ARP
								;;0x8035 RARP
								;;0x86DD IPv6
	
		

IPv4packet:	;;160 to 480 bits

	IPv4header:

		db 01000101b	;;4 bits-ip version = 4
				;;4 bits-header length = 5*4 = 20 bytes

		db 00000000b	;;8 bits-type of service
					;;b0\
					;;b1-Precedence = 0
					;;b2/
					;;b3-Delay = 0
					;;b4-Throughput = 0
					;;b5-Reliability = 0
					;;b6-Reserved = 0
					;;b7/

		db 0x00,0x30	;;16 bits-total length = 48 bytes

		db 0x1C,0x81	;;16 bits-identification = 0x1C81

		db 01000000b,00000000b	;;3 bits-flags
						;;b0-Reserved = 0
						;;b1-Don't Fragment = 1
						;;b2-More Fragments = 0
					;;13 bits-fragment offset = 0

		db 0x80			;;8 bits-time to live = 128
					;;-1 every iteration

		db 0x06		;;8 bits-protocol = 0x06
					;;0x00 Reserved
					;;0x01 ICMP
					;;0x02 IGMP
					;;0x03 GGP
					;;0x04 IP-in-IP Encapsulation
					;;0x06 TCP
					;;0x08 EGP
					;;0x11 UDP
					;;0x32 ESP Extension Header
					;;0x33 AH Extention Header

		db 0x5C,0xF0	;;16 bits-header checksum = 0x5CF0
					;;sum of 16 bit words in header, masked to 16 bits

		db 192,168,0,5	;;32 bits-source address

		db 192,168,0,1	;;32 bits-destination address
		
	IPv4headerend:
		
		
		
TCPsegment:	;;160 bits to 1460 bits

TCPheader:			
		db 0x08,0xE9	;;16 bits-source port = 2281

		db 0x00,0x50	;;16 bits-destination port = 80

		db 0x24,0x6E,0x0E,0x56	;;32 bits-sequence number = 0 (relatively, see below)
						;;If SYN flag is set, this is the initial sequence number, sequence number of 1st byte=this+1
						;;If SYN flag is not set, this is the sequence number of the first data byte

		db 0x00,0x00,0x00,0x00	;;32 bits-acknowledgment number = 0
						;;If ACK flag is set, the value in this field is the next expected byte

		db 01110000b	;;4 bits-data offset = 7*4 = 28 bytes
					;;size of header in 32-bit words, minimum of 5
				;;4 bits-reserved = 0

		db 00000010b	;;8 bits-flags
					;;b0-CWR = 0
						;;Congested Window Reduced-indicates that sending host received segment with ECE flag set
					;;b1-ECE = 0
						;;ECN Echo-indicates that tcp peer is ECN capable during 3-way handshake
					;;b2-URG = 0
						;;indicates that urgent pointer field is significant
					;;b3-ACK = 0
						;;indicates that acknowledgment field is significant
					;;b4-PSH = 0
						;;push function
					;;b5-RST = 0
						;;reset connection
					;;b6-SYN = 1
						;;synchronize sequence numbers
					;;b7-FIN = 0
						;;no more data from sender

		db 0x40,0x00	;;16 bits-window size = 16384 bytes
					;;number of bytes that the receiver is willing to receive

		db 0x85,0xCB	;;16 bits-checksum = 0x85CB
					;;sum of all 16 bit words of header masked to 16 bits

		db 0x00,0x00	;;16 bits-urgent pointer = 0
					;;if URG is set, this is an offset from the sequence number indicating the last urgent data byte
				
		;;OPTIONS HERE

		db 0x02,0x04	;;Max segment size
		db 0x05,0xB4	;;is 1460 bytes

		db 0x01		;;NOP

		db 0x01		;;NOP

		db 0x04,0x02	;;SACK Permitted

TCPheaderdone:

TCPsegmentend:
		
IPv4packetend:
		
ethernetIItrail:

		db 0x3F,0x07,0x30,0x8F		;;32 bit CRC, calculated by NIC

ethernetIItrailend:

ethernetIIframeend:	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;OTHER PACKET/SEGMENT TYPES THAT CAN BE USED;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;0000  ff ff ff ff ff ff 00 1c df 0c 38 e5 08 06 00 01   ........O.......
;;0010  08 00 06 04 00 01 00 1c df 0c 38 e5 c0 a8 00 05   ........O.......
;;0020  00 00 00 00 00 00 c0 a8 00 01                     ..........

ARPpacket:	;;example ARP packet requesting MAC for IP address 192.168.0.1
		;;always sent to FF:FF:FF:FF:FF for broadcast

		db 0x00,0x01		;;Hardware type = 1
						;;1=ethernet

		db 0x08,0x00		;;Protocol type = 0x0800
						;;same as ethertype however ARP type 0x0806 may not be used

		db 0x06			;;Hardware address length = 6
						;;MAC is 6 bytes long

		db 0x04			;;Protocol address length = 4
						;;IPv4 is 4 bytes long

		db 0x00,0x01		;;Operation = 1
						;;1=request
						;;2=reply

		db 0x00,0x1C,0xDF,0x0C,0x38,0xE5	;;Sender hardware address = 00:1C:DF:0C:38:E5
								;;should have length specified in Hardware address length

		db 192,168,0,5		;;Sender Protocol address = 192.168.0.5
						;;should have length specified in Protocol address length

		db 0x00,0x00,0x00,0x00,0x00,0x00	;;Target hardware address, ignored in requests

		db 192,168,0,1		;;Target protocal address = 192.168.0.1