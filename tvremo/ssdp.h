//
//  ssdp.h
//  tvremo
//

#ifndef ssdp_h
#define ssdp_h

#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

    int sendSSDP(const int sock);
    int initSSDP(const char *sendIfIpAddr); // Return Value is socket
    long recvSSDP(const int sock, char *buf, int bufLen, char *ipaddr, int ipaddrLen);
    void finalSSDP(const int sock);

#ifdef __cplusplus
}
#endif

#endif /* ssdp_h */
