module deimos.XCB.xcbext;
import deimos.XCB.xcb;
import std.stdint;
import core.sys.posix.sys.uio;   // for iovec

extern (C) nothrow:

/* xcb_ext.c */

struct xcb_extension_t {
    const char *name;
    int global_id;
};


/* xcb_out.c */

struct xcb_protocol_request_t {
    size_t count;
    xcb_extension_t *ext;
    uint8_t opcode;
    uint8_t isvoid;
}

enum xcb_send_request_flags_t {
    XCB_REQUEST_CHECKED = 1 << 0,
    XCB_REQUEST_RAW = 1 << 1,
    XCB_REQUEST_DISCARD_REPLY = 1 << 2
};

uint xcb_send_request(xcb_connection_t *c, int flags, iovec *vector, const xcb_protocol_request_t *request);

/* xcb_take_socket allows external code to ask XCB for permission to
 * take over the write side of the socket and send raw data with
 * xcb_writev. xcb_take_socket provides the sequence number of the last
 * request XCB sent. The caller of xcb_take_socket must supply a
 * callback which XCB can call when it wants the write side of the
 * socket back to make a request. This callback synchronizes with the
 * external socket owner and flushes any output queues if appropriate.
 * If you are sending requests which won't cause a reply, please note the
 * comment for xcb_writev which explains some sequence number wrap issues.
 * */
int xcb_take_socket(xcb_connection_t *c, void function(void *closure) return_socket, void *closure, int flags, uint64_t *sent);

/* You must own the write-side of the socket (you've called
 * xcb_take_socket, and haven't returned from return_socket yet) to call
 * xcb_writev. Also, the iovec must have at least 1 byte of data in it.
 * You have to make sure that xcb can detect sequence number wraps correctly.
 * This means that the first request you send after xcb_take_socket must cause a
 * reply (e.g. just insert a GetInputFocus request). After every (1 << 16) - 1
 * requests without a reply, you have to insert a request which will cause a
 * reply. You can again use GetInputFocus for this. You do not have to wait for
 * any of the GetInputFocus replies, but can instead handle them via
 * xcb_discard_reply(). */
int xcb_writev(xcb_connection_t *c, iovec *vector, int count, uint64_t requests);


/* xcb_in.c */

void *xcb_wait_for_reply(xcb_connection_t *c, uint request, xcb_generic_error_t **e);
int xcb_poll_for_reply(xcb_connection_t *c, uint request, void **reply, xcb_generic_error_t **error);


/* xcb_util.c */

int xcb_popcount(uint32_t mask);
int xcb_sumof(uint8_t *list, int len);
