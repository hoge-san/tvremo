//
//  ssdp.c
//  tvremo
//

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/time.h>

#include "ssdp.h"
#define SEND_TIMES 3

static char ssdpMsg[] = "\
M-SEARCH * HTTP/1.1\r\n\
HOST: 239.255.255.250:1900\r\n\
MAN: \"ssdp:discover\"\r\n\
MX: 3\r\n\
ST:upnp:rootdevice\r\n\r\n\r\n";

int
sendSSDP(const int sock){
    int ret=0;
    struct sockaddr_in addr;

    addr.sin_family = AF_INET;
    addr.sin_port = htons(1900);
    addr.sin_addr.s_addr = inet_addr("239.255.255.250");
    int i;
    for(i = 0; i < SEND_TIMES; i ++) {
        ret = (int)sendto(sock, ssdpMsg, sizeof(ssdpMsg), 0,
                          (struct sockaddr *)&addr, sizeof(addr));
        if(ret < 0) {
            return -1;
        }
    }
    return ret;
}


int
initSSDP(const char *sendIfIpAddr)
{
    int sock;
    //    struct sockaddr_in addr;
    in_addr_t ipaddr;

    sock = socket(AF_INET, SOCK_DGRAM, 0);
    if(sock < 0 ) {
        return -1;
    }

    ipaddr = inet_addr(sendIfIpAddr);
    if (setsockopt(sock, IPPROTO_IP, IP_MULTICAST_IF,
                   (char *)&ipaddr, sizeof(ipaddr)) != 0) {
        close(sock);
        return -1;
    }

    int ttl = 2;
    if (setsockopt(sock,IPPROTO_IP, IP_MULTICAST_TTL,
                   (char *)&ttl, sizeof(ttl)) != 0) {
        close(sock);
        return -1;
    }
    return sock;
}


void
finalSSDP(const int sock) {
    close(sock);
}

long
recvSSDP(const int sock, char *buf, int bufLen, char *ipaddr, int ipaddrLen)
{
    fd_set readfds, fds;
    int n;
    struct timeval tv;
    socklen_t sinSize;
    struct sockaddr_in sin;

    sinSize = sizeof(struct sockaddr_in);

    FD_ZERO(&readfds);
    FD_SET(sock, &readfds);

    tv.tv_sec = 3;
    tv.tv_usec = 0;

    while (1) {
        memcpy(&fds, &readfds, sizeof(fd_set));
        n = select(sock+1, &fds, NULL, NULL, &tv);
        if(n < 0) {
            return -1;
        }
        if(n == 0 ) { //timeout
            return -1;
        }
        if (FD_ISSET(sock, &fds)) {
            memset(buf, 0, bufLen);
            memset(&sin, 0, sizeof(struct sockaddr_in));
            ssize_t len = recvfrom(sock, buf, bufLen, 0, (struct sockaddr *)&sin,
                                   &sinSize);
            if(len > 0) {
                inet_ntop(AF_INET, &sin.sin_addr, ipaddr, ipaddrLen);
            }
            return len;
        }

    }
}
