#!/usr/bin/python3

# source: https://gist.github.com/Chubek/1fb8997bed45d744342a8a28fdcde749

# python3 <scriptname> --help for help

# this script contain a simple, limited implementation of the
# DNS query system in Python
# notice that this script is not a complete implementation
# and has only been written for prototyping DNS resolver
# please only use for educational/prototyping purposes

# based on RFC 1035: https://datatracker.ietf.org/doc/html/rfc1035
# also RFC 3596 for AAAA: https://datatracker.ietf.org/doc/html/rfc3596

from ctypes import c_ushort
from socket import AF_INET, SOCK_DGRAM, socket

# Part A: Globals & Utils

MAXU16 = 65535  # maximum of u16
ASCII_PERIOD = 46  # ascii for period
LEN_HEADER = 12  # length of DNS query header

RECURSE_DESIRED = 1  # setting this flag means we want recursive lookup
RECURSE_UNDESIRED = 0  # and this means recurse is undesired

RCODE_FORMATERROR = -1  # these are the 5 return codes of a dns query
RCODE_SERVERFAIL = -2  # format and name error, server fail, implementation issues
RCODE_NAMEERROR = -3  # and refused error, you can view all these in RFC 1035 page
RCODE_NOTIMPLEMENTED = -4  # 27 --- notice that these are not signed, however, we sign them
RCODE_REFUSED = -5  # because we wish to return them as signed values in case of error

ERROR_XIDMISMATCH = -6  # these two are the additional errors we wish to add
ERROR_NORECURSION = -7  # xid mismatch, and no recursion being available in resolver

CLASS_INTERNET = 1  # this is the resource class for internet, we will set it as default for obvious reasosn

RECORD_A = 1  # marks A record type
RECORD_CNAME = 5  # marks CNAME record type
RECORD_TXT = 16  # marks TXT record type
RECORD_AAAA = 28  # marks AAAA record type

ENCODINGS_PY = [
    'ascii',  # this is a list of all the Python text codecs
    'big5',  # we will use them at the end to decode  CNAME and TXT records
    'big5hkscs',
    'cp037',
    'cp273',
    'cp424',
    'cp437',
    'cp500',
    'cp720',
    'cp737',
    'cp775',
    'cp850',
    'cp852',
    'cp855',
    'cp856',
    'cp857',
    'cp858',
    'cp860',
    'cp861',
    'cp862',
    'cp863',
    'cp864',
    'cp865',
    'cp866',
    'cp869',
    'cp874',
    'cp875',
    'cp932',
    'cp949',
    'cp950',
    'cp1006',
    'cp1026',
    'cp1125',
    'cp1140',
    'cp1250',
    'cp1251',
    'cp1252',
    'cp1253',
    'cp1254',
    'cp1255',
    'cp1256',
    'cp1257',
    'cp1258',
    'euc_jp',
    'euc_jis_2004',
    'euc_jisx0213',
    'euc_kr',
    'gb2312',
    'gbk',
    'gb18030',
    'hz',
    'iso2022_jp',
    'iso2022_jp_1',
    'iso2022_jp_2',
    'iso2022_jp_2004',
    'iso2022_jp_3',
    'iso2022_jp_ext',
    'iso2022_kr',
    'latin_1',
    'iso8859_2',
    'iso8859_3',
    'iso8859_4',
    'iso8859_5',
    'iso8859_6',
    'iso8859_7',
    'iso8859_8',
    'iso8859_9',
    'iso8859_10',
    'iso8859_11',
    'iso8859_13',
    'iso8859_14',
    'iso8859_15',
    'iso8859_16',
    'johab',
    'koi8_r',
    'koi8_t',
    'koi8_u',
    'kz1048',
    'mac_cyrillic',
    'mac_greek',
    'mac_iceland',
    'mac_latin2',
    'mac_roman',
    'mac_turkish',
    'ptcp154',
    'shift_jis',
    'shift_jis_2004',
    'shift_jisx0213',
    'utf_32',
    'utf_32_be',
    'utf_32_le',
    'utf_16',
    'utf_16_be',
    'utf_16_le',
    'utf_7',
    'utf_8',
    'utf_8_sig',
    'utf8',
    'utf16',
    'utf32',
    'utf-8',
    'utf-16',
    'utf-32'
]

errors_explain = {
    str(RCODE_FORMATERROR): "This is an rcode error, as specified by the RFC. This means there was a format error in the query.",
    str(RCODE_SERVERFAIL): "This is an rcode error, as specified by the RFC. This means there was a server failure on the resolver's par, but sometimes it just means the formatting was wrong.",
    str(RCODE_NAMEERROR): "This is an rcode error, as specified by the RFC. This means there was a problem with the DNS address, maybe it is not registered, or the resolver does not support it.",
    str(RCODE_NOTIMPLEMENTED): "This is an rcode error, as specified by the RFC. This means the resolver does not support the query type.",
    str(RCODE_REFUSED): "This is an rcode error, as specified by the RFC. This means the resolver has refused to honor this query",
    str(ERROR_XIDMISMATCH): "This is a DNSRezulf error, This means the resolver sent an XID that did not match the XID we sent to it.",
    str(ERROR_NORECURSION): "This is a DNSRezulf error, this means although we specified recursion, the resolver does not support it.",
}


def dataclass(cls: type) -> type:
    args = {k: v for k, v in cls.__dict__.items() if not k.startswith("__")}

    def init(self, **args):
        for k, v in args.items():
            exec(f"self.{k} = {v}")

    def str(self):
        string = ""
        for k in self.__class__.__dict__:
            if not k.startswith("__"):
                val = eval(f'self.{k}')
                string += f"{k} -> {val}\n"
        return string

    cls.__init__ = init
    cls.__str__ = str
    return cls


def generate_random_ushort() -> int:  # this function generates a random unsigned 16-bit integer
    from time import time_ns  # we use it for XID generation
    seed = time_ns()
    return c_ushort(((seed << 5) + seed) % MAXU16).value


def error_out(message: str):
    print("\033[1;31mError occured\033[0m")
    print(message)
    exit(1)


def get_executable_name() -> str:
    from sys import executable
    from pathlib import Path
    return Path(executable).name


def get_script_name() -> str:
    from sys import argv
    return argv[0]


# this function decodes TXT and CNAME data based on the given codec in CMD
def decode_record_rdata(codec: str, rdata: bytearray) -> str:
    execname = get_executable_name()
    scriptname = get_script_name()
    if codec[:3] == "raw":
        return "bytearray[ " + ', '.join([str(int(b)) for b in rdata]) + "]"
    elif codec == 'brute':
        for enc in ENCODINGS_PY:
            try:
                return rdata.decode(enc)
            except:
                continue
            finally:
                print("None of Python's codecs could decode the result, printing it raw...")
                return "[ " + ', '.join([str(int(b)) for b in rdata]) + "]"
    else:
        if codec not in ENCODINGS_PY:
            error_out(
                f"Encoding {codec} is not present in Python's list of available codecs\nPlease pass `{execname} {scriptname} --encoding list` to see a full list of available codecs")
        else:
            try:
                return rdata.decode(codec)
            except:
                print("Your selected codec could not decode the record data, returning raw...")
            finally:
                return "[ " + ', '.join([str(int(b)) for b in rdata]) + "]"


# Part B: Types

# this is the header for both response and question

@dataclass
class DNSQueryHeader:
    xid = 0  # a random 16-bit unsigned ID
    qr = 0  # question or response? One bit only
    opcode = 0  # four bits. What type of query is it? We always set it to squery (standard querey)
    aa = 0  # Authoratic Answer or not  --- one bit
    tc = 0  # has it be truncated? one bit
    rd = 0  # only in question, is recursion desired? --- one bit
    ra = 0  # only in response, is recursion available? --- one bit
    z = 0  # always set to 0 --- three bits
    rcode = 0  # response code, 4 bits
    qdcount = 1  # 16-bit unsigned, question count
    ancount = 0  # 16-bit unsigned, answer count
    nscount = 0  # 16-bit unsigned, name authority record count
    arcount = 0  # 16-bit unsigned, additional record count


# this is format of a question, there can be several, but we'll just send one

@dataclass
class DNSQueryQuestion:
    qname = b""  # variable, name of the desired domain, null-terminated
    qtype = 0  # type of the question, 16-bit unsigned
    qclass = CLASS_INTERNET  # class of the question, 16-bit unsigned


# this is format of a response resource record, there can be several, but we'll just send one

@dataclass
class DNSResourceRecord:
    name = b""  # variable, human-readable name of the domain
    rtype = 0  # unsigned 16-bit integer, type of the resource
    rclass = CLASS_INTERNET  # unsigned 16-bit integer, class of the resource
    ttl = 0  # unsigned 16-bit integer, time interval until caching is valid
    rdlength = 0  # unsigned 16-bit integer, length of rdata
    rdata = b""  # variable, the data, for A and AAA it's the IPV4 and IPV6


# Part C: DNS Query Protocol

# this function will encode the dns address to (len, section, len, section..., NULL) form as specified by the RFC
# basically every section is separated by period (46 ascii) and they must come separated with their length before them
# we then must null-terminate the bytestring

def encode_dns_addr(addr: bytearray) -> bytearray:
    qname = bytearray([0])
    idxcntr = 0
    for i, c in enumerate(addr):
        if c == ASCII_PERIOD:
            qname.append(0)
            idxcntr = i + 1  # in case we hit a period, we append a zero which will be the length of the new
            continue  # section and we set the index of counter to it, then we continue
        qname[idxcntr] += 1  # otherwise, we increase the index
        qname.append(c)  # and append the byte
    qname.append(0)  # we must null-terminate
    return qname


# simple, make a new question object

def new_dns_query_question(addr: str, qtype=RECORD_A) -> bytearray:
    qname = encode_dns_addr(addr)
    return DNSQueryQuestion(qname=qname, qtype=qtype)


# make a new header object

def new_dns_query_header(rd=RECURSE_DESIRED):
    return DNSQueryHeader(xid=generate_random_ushort(), rd=rd)


# encode the query header, as specified by the RFC
# the options are 16-bits, and as the net byte order goes, big-endian

def encode_dns_query_header(header: DNSQueryHeader) -> bytearray:
    xid = header.xid.to_bytes(2, byteorder="big", signed=False)
    qr = (header.qr & 1) << 15
    opcode = (header.opcode & 15) << 11
    aa = (header.aa & 1) << 10
    tc = (header.tc & 1) << 9
    rd = (header.rd & 1) << 8
    ra = (header.ra & 1) << 7
    z = (header.z & 7) << 4
    rcode = header.rcode & 15
    flags = (qr | opcode | aa | tc | rd | ra | z | rcode).to_bytes(2, byteorder='big')
    qdcount = header.qdcount.to_bytes(2, byteorder='big', signed=False)
    ancount = header.ancount.to_bytes(2, byteorder='big', signed=False)
    nscount = header.nscount.to_bytes(2, byteorder='big', signed=False)
    arcount = header.arcount.to_bytes(2, byteorder='big', signed=False)
    return xid + flags + qdcount + ancount + nscount + arcount


def encode_dns_query_question(question: DNSQueryQuestion):
    qtype = question.qtype.to_bytes(2, byteorder="big")
    qclass = question.qclass.to_bytes(2, byteorder="big", signed=False)
    return question.qname + qtype + qclass


# encode the final packet for request

def encode_dns_query_packet(header: DNSQueryHeader, question: DNSQueryQuestion) -> bytearray:
    return encode_dns_query_header(header) + encode_dns_query_question(question)


# decoding the header is similiar to encoding the header, we just have to reverse the flag and turn bytes into integers instead

def decode_dns_query_header(response: bytes) -> DNSQueryHeader:
    response = response[1:]
    xid = c_ushort(int.from_bytes(response[:2], byteorder="big", signed=False)).value
    flags = int.from_bytes(response[2:4], byteorder="big", signed=False)
    qr = (flags & 32768) >> 15
    opcode = (flags & 30720) >> 11
    aa = (flags & 1024) >> 10
    tc = (flags & 512) >> 9
    rd = (flags & 256) >> 8
    ra = (flags & 128) >> 7
    z = (flags & 56) >> 4
    rcode = flags & 15
    qdcount = int.from_bytes(response[4:6], byteorder="big", signed=False)
    ancount = int.from_bytes(response[6:8], byteorder="big", signed=False)
    nscount = int.from_bytes(response[8:10], byteorder="big", signed=False)
    arcount = int.from_bytes(response[10:12], byteorder="big", signed=False)
    return DNSQueryHeader(xid=xid, qr=qr, opcode=opcode, aa=aa, tc=tc, rd=rd, ra=ra, z=z, rcode=rcode, qdcount=qdcount,
                          ancount=ancount, nscount=nscount, arcount=arcount)


# decoding the dns query record is partly similar to the encoding of address
# we must start at byte 12, and add the bytes to our address name until we hit zero
# we then decode type, class and ttl
# after that, we get the length, and grab from that point on, plus rdlength
# that will give us our data

def decode_dns_query_resource_record(response: bytearray) -> DNSResourceRecord:
    idx = LEN_HEADER  # we add length of the header to our cursor
    byte = 255
    name = bytearray([])
    while True:
        if byte == 0:
            break
        idx += 1
        name.append(byte)
        byte = response[idx]
    idx += 7  # we add the question offset to our cursor
    response = response[idx:]
    rtype = int.from_bytes(response[:2], byteorder="big", signed=False)
    rclass = int.from_bytes(response[2:4], byteorder="big", signed=False)
    ttl = int.from_bytes(response[4:8], byteorder="big", signed=True)
    rdlength = int.from_bytes(response[8:10], byteorder="big", signed=False)
    rdata = response[10:10 + rdlength]
    return DNSResourceRecord(name=name, rtype=rtype, rclass=rclass, ttl=ttl, rdlength=rdlength, rdata=rdata)


def generate_and_compose_query(address: str, rectype=RECORD_A, recursive=RECURSE_DESIRED) -> tuple[bytes, int]:
    header = new_dns_query_header(recursive)
    question = new_dns_query_question(address, rectype)
    return encode_dns_query_packet(header, question), header.xid


def parse_server_response(response: bytearray, xid: c_ushort, recursion=RECURSE_DESIRED, record=None) -> bytes:
    header = decode_dns_query_header(response)
    # check for errors in response
    if header.xid != xid:
        return ERROR_XIDMISMATCH  # the XID given does not match with XID returned
    elif header.ra != recursion:
        return ERROR_NORECURSION  # if we have set recursion to true, and server does not support it
    elif header.rcode:
        return -header.rcode  # we sign-extend the rcode if it is non-zero and return it
    record = decode_dns_query_resource_record(response)
    return record


# Part D: Resolver

# the resolver interface puts everything we made prior together

class DNSResolver:
    def __init__(self, resolver="8.8.8.8", port=53, bufsize=1024):
        self.resolver = resolver
        self.port = port
        self.bufsize = bufsize
        self.socket = socket(AF_INET, SOCK_DGRAM)  # open a socket to the resolver server

    def connect_to_resolver(self):
        self.socket.connect((self.resolver, self.port))  # connect to the socket

    def send_and_receive_query_and_parse_results(self, addr: str, rectype=RECORD_A, recursion=RECURSE_DESIRED,
                                                 retries=3, record=None) -> bytes:
        packet, xid = generate_and_compose_query(addr, rectype, recursion)  # generate the packet
        lenpacket = len(packet)
        sent = self.socket.send(packet)  # send the packet
        while sent != lenpacket:  # retry if send fails
            if retries < 0:
                break
            sent = self.socket.send(packet)
            retries -= 1
        response = bytearray([0])
        while True:
            received_data = self.socket.recv(self.bufsize)  # get the response
            response += received_data
            if len(received_data) < self.bufsize:
                break
        return parse_server_response(response, xid, recursion)  # parse the response

    def close_connection(self):
        self.socket.close()


if __name__ == "__main__":
    from sys import argv

    execname = get_executable_name()
    scriptname = get_script_name()
    argv = argv[1:]

    params = {
        "resolver": ["--resolver", "-rs"],
        "port": ["--port", "-p"],
        "address": ["--address", "-ad"],
        "rectype": ["--rectype", "-rr"],
        "recursion": ["--recursion", "-re"],
        "codec": ["--encoding", "-en"],
        "errors": ["--errors", "-er"]
    }

    if "--help" in argv or "-h" in argv:
        print("\033[1;33mDNSRezulf by Chubak Bidpaa\033[0m")
        print("Released under MIT License")
        print(f"DNSRezulf ({scriptname}) is a very simple DNS Resolver. Think, a watered down version of dig.")
        print(
            "You may request A, AAAA, CNAME and TXT records with it. You may specify whether the search is recursive or not.")
        print("The default resolver in 8.8.8.8, which is Google's resolver. But you may select a different one.")
        print("If you pass `list` to --encoding, it will print all the available codecs, and exit.")
        print("If you pass an error code to --errors, it will explain the error code, and exit.")
        print("Only standard queries are available. No inverse query and whatnot.")
        print()
        print("\033[1mArguments:")
        print("[Long/Short]; Purpose; Default")
        print("[--resolver/-rs]; DNS Resolver Server; 8.8.8.8")
        print("[--port/-p]; DNS Resolver Port; 53")
        print("[--address/-ad]; Address to Resolver; example.com")
        print("[--rectype/-rr]; R Type; A")
        print("[--recursion/-re]; Recursive Search; 1")
        print("[--encoding/-en]; CNAME/TXT Codec; raw")
        print("[--errors/-er; Error code explain; None")
        print("\033[0m")
        print(f"Example: {execname} {scriptname} -ad google.com --rectype AAAA")
        print(f"On Unix-like systems, this script can be ran via the Shebang: {scriptname} -rs 1.1.1.1 -ad reddit.com")
        exit(1)

    args = {
        "resolver": "8.8.8.8",
        "port": "53",
        "address": "example.com",
        "rectype": "A",
        "recursion": "1",
        "codec": "raw",
        "errors": None,
    }

    all_params = sum(params.values(), [])
    skip = False
    for arg in argv:
        if skip:
            args[skip] = arg
            skip = False
            continue
        if arg in all_params:
            for k, v in params.items():
                if arg in v:
                    skip = k
        else:
            error_out(f"Illegal parameter: {arg}")

    if args['errors'] is not None:
        errcode = args['errors']
        if errcode not in errors_explain:
            error_out("Wrong error code passed to --errors")
        print(errors_explain.get(errcode))
        exit(1)

    if args['codec'] == 'list':
        print("\n".join(ENCODINGS_PY))
        exit(1)

    if not args["port"].isdigit():
        error_out("Port must be digits")
    port = int(args["port"])
    if port < 0 or port > MAXU16:
        error_out("Port must be between 0 and 65535")

    resolver = args["resolver"]
    address = args["address"].encode("ascii")
    rectype = args["rectype"]

    if rectype == "A":
        rectype = RECORD_A
    elif rectype == "AAAA":
        rectype = RECORD_AAAA
    elif rectype == "CNAME":
        rectype = RECORD_CNAME
    elif rectype == "TXT":
        rectype = RECORD_TXT
    else:
        error_out("Wrong record type")

    recursion = args["recursion"]
    if recursion not in ["1", "0"]:
        error_out("Recursion must be 0 or 1")
    recursion = bool(recursion)

    dnsresolver = DNSResolver(resolver, port)
    dnsresolver.connect_to_resolver()
    queryresult = dnsresolver.send_and_receive_query_and_parse_results(addr=address, rectype=rectype,
                                                                       recursion=recursion)
    dnsresolver.close_connection()

    if type(queryresult) == int and queryresult < 0:
        error_out(
            f"Error ocurred, code: {queryresult}\nPlease type in {execname} {scriptname} --errors {queryresult} to inspect")

    data = queryresult.rdata
    ttl = queryresult.ttl
    address = address.decode()

    if rectype in [RECORD_TXT, RECORD_CNAME]:
        data = decode_record_rdata(args['codec'], data)

    if rectype == RECORD_A:
        print(f"\t{address} | A | ttl={ttl} | {'.'.join([str(c) for c in data])}")
    elif rectype == RECORD_AAAA:
        print(
            f"\t{address} | AAAA | ttl={ttl} | {':'.join([format(int.from_bytes([c1, c2], byteorder='big', signed=False), 'x') for c1, c2 in zip(data[::2], data[1::2])])}")
    elif rectype == RECORD_TXT:
        print(f"\t{address} | TXT | ttl={ttl} | `{data}`")
    else:
        print(f"\t{address} | CNAME | ttl={ttl} | `{data}`")
