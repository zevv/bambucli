
import std/net
import std/asyncnet
import std/asyncdispatch
import std/strutils
import std/tables


type
  DiscoverResult* = object
    usn*: string
    location*: string

proc set_mcast(fd: cint, address: cstring, port: cint) {.importc.}


{.emit:"""
#include <arpa/inet.h>
#include <sys/socket.h>

// Pretty crappy that Nim does not come with multicast support
void set_mcast(int fd, char *addr, int port)
{
    setsockopt(fd, SOL_SOCKET, SO_BROADCAST, &(int){1}, sizeof(int));
    setsockopt(fd, SOL_IP, IP_ADD_MEMBERSHIP, &(struct ip_mreq){.imr_multiaddr.s_addr = inet_addr(addr), .imr_interface.s_addr = INADDR_ANY}, sizeof(struct ip_mreq));
    setsockopt(fd, SOL_IP, IP_MULTICAST_TTL, &(int){4}, sizeof(int));
}
""".}
  


proc discover*(): Future[DiscoverResult] {.async.} =

  let address = "239.255.255.250"
  let port = 2021
    
  let q = 
    "M-SEARCH * HTTP/1.1\r\n" &
    "HOST:" & address & ":" & $port & "\r\n" &
    "MAN:\"ssdp:discover\"\r\n" &
    "MX:1\r\n" &
    "ST:urn:bambulab-com:device:3dprinter:1\r\n" &
    "USER-AGENT:OS/version product/version\r\n" &
    "\r\n"

  let sock = newAsyncSocket(AF_INET, SOCK_DGRAM, IPPROTO_UDP, false)
  set_mcast(sock.getFd().cint, address.cstring, port.cint)
  await sock.sendTo(address, Port(port), q)
  let rsp = await sock.recv(1500)

  let lines = rsp.splitLines()
  var headers = initTable[string, string]()
  for line in lines:
    let parts = line.split(":")
    if parts.len == 2:
      headers[parts[0].strip().toLowerAscii] = parts[1].strip()

  DiscoverResult(usn: headers["usn"], location: headers["location"])


