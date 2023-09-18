
import std/net
import std/asyncnet
import std/asyncdispatch
import std/strutils
import std/tables


type
  DiscoverResult* = object
    device*: string
    ip*: string


# Pretty crappy that Nim's stdlib does not come with multicast support

proc set_mcast(fd: cint, address: cstring) {.importc.}

{.emit:"""
#ifdef WIN32
#include <winsock2.h>
#include <windows.h>
#include <ws2tcpip.h>
#include <mswsock.h>
#else
#include <arpa/inet.h>
#include <sys/socket.h>
#endif

void set_mcast(int fd, char *addr)
{
    struct ip_mreq mreq;
    memset(&mreq, 0, sizeof(mreq));
    mreq.imr_multiaddr.s_addr = inet_addr(addr);
    mreq.imr_interface.s_addr = INADDR_ANY;
    setsockopt(fd, IPPROTO_IP, IP_ADD_MEMBERSHIP, (char *)&mreq, sizeof(mreq));

    int yes = 1;
    setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, (char *)&yes, sizeof(yes));
    
    int ttl = 4;
    setsockopt(fd, IPPROTO_IP, IP_MULTICAST_TTL, (char *)&ttl, sizeof(ttl));
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
  set_mcast(sock.getFd().cint, address.cstring)
  await sock.sendTo(address, Port(port), q)
  let rsp = await sock.recv(1500)

  let lines = rsp.splitLines()
  var headers = initTable[string, string]()
  for line in lines:
    let parts = line.split(":")
    if parts.len == 2:
      headers[parts[0].strip().toLowerAscii] = parts[1].strip()

  return DiscoverResult(device: headers["usn"], ip: headers["location"])


