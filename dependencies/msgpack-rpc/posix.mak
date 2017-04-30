# build mode: 32bit or 64bit
MODEL ?= $(shell getconf LONG_BIT)

ifeq (,$(DMD))
	DMD := dmd
endif

LIB     = libmsgpackrpcd.a
DFLAGS  = -Isrc -m$(MODEL) -w -d -property -version=VibeLibeventDriver

ifeq ($(BUILD),debug)
	DFLAGS += -g -debug
else
	DFLAGS += -O -release -nofloat -inline # -noboundscheck # dmd has a optimization bug
endif

ifeq ($(EnableReal),true)
	DFLAGS += -version=EnableReal
endif

SRCS  = \
	src/deimos/event2/_d_util.d \
	src/deimos/event2/_tailq.d \
	src/deimos/event2/buffer.d \
	src/deimos/event2/bufferevent.d \
	src/deimos/event2/bufferevent_ssl.d \
	src/deimos/event2/dns.d \
	src/deimos/event2/dns_struct.d \
	src/deimos/event2/event.d \
	src/deimos/event2/event_struct.d \
	src/deimos/event2/http.d \
	src/deimos/event2/http_struct.d \
	src/deimos/event2/keyvalq_struct.d \
	src/deimos/event2/listener.d \
	src/deimos/event2/rpc.d \
	src/deimos/event2/rpc_struct.d \
	src/deimos/event2/tag.d \
	src/deimos/event2/thread.d \
	src/deimos/event2/util.d \
	src/deimos/openssl/_d_util.d \
	src/deimos/openssl/aes.d \
	src/deimos/openssl/asn1.d \
	src/deimos/openssl/asn1_mac.d \
	src/deimos/openssl/asn1t.d \
	src/deimos/openssl/bio.d \
	src/deimos/openssl/blowfish.d \
	src/deimos/openssl/bn.d \
	src/deimos/openssl/buffer.d \
	src/deimos/openssl/camellia.d \
	src/deimos/openssl/cast_.d \
	src/deimos/openssl/cms.d \
	src/deimos/openssl/comp.d \
	src/deimos/openssl/conf.d \
	src/deimos/openssl/conf_api.d \
	src/deimos/openssl/crypto.d \
	src/deimos/openssl/des.d \
	src/deimos/openssl/des_old.d \
	src/deimos/openssl/dh.d \
	src/deimos/openssl/dsa.d \
	src/deimos/openssl/dso.d \
	src/deimos/openssl/dtls1.d \
	src/deimos/openssl/e_os2.d \
	src/deimos/openssl/ebcdic.d \
	src/deimos/openssl/ec.d \
	src/deimos/openssl/ecdh.d \
	src/deimos/openssl/ecdsa.d \
	src/deimos/openssl/engine.d \
	src/deimos/openssl/err.d \
	src/deimos/openssl/evp.d \
	src/deimos/openssl/hmac.d \
	src/deimos/openssl/idea.d \
	src/deimos/openssl/krb5_asn.d \
	src/deimos/openssl/kssl.d \
	src/deimos/openssl/lhash.d \
	src/deimos/openssl/md4.d \
	src/deimos/openssl/md5.d \
	src/deimos/openssl/mdc2.d \
	src/deimos/openssl/modes.d \
	src/deimos/openssl/obj_mac.d \
	src/deimos/openssl/objects.d \
	src/deimos/openssl/ocsp.d \
	src/deimos/openssl/opensslconf.d \
	src/deimos/openssl/opensslv.d \
	src/deimos/openssl/ossl_typ.d \
	src/deimos/openssl/pem.d \
	src/deimos/openssl/pem2.d \
	src/deimos/openssl/pkcs12.d \
	src/deimos/openssl/pkcs7.d \
	src/deimos/openssl/pqueue.d \
	src/deimos/openssl/rand.d \
	src/deimos/openssl/rc2.d \
	src/deimos/openssl/rc4.d \
	src/deimos/openssl/ripemd.d \
	src/deimos/openssl/rsa.d \
	src/deimos/openssl/safestack.d \
	src/deimos/openssl/seed.d \
	src/deimos/openssl/sha.d \
	src/deimos/openssl/ssl.d \
	src/deimos/openssl/ssl2.d \
	src/deimos/openssl/ssl23.d \
	src/deimos/openssl/ssl3.d \
	src/deimos/openssl/stack.d \
	src/deimos/openssl/symhacks.d \
	src/deimos/openssl/tls1.d \
	src/deimos/openssl/ts.d \
	src/deimos/openssl/txt_db.d \
	src/deimos/openssl/ui.d \
	src/deimos/openssl/ui_compat.d \
	src/deimos/openssl/whrlpool.d \
	src/deimos/openssl/x509.d \
	src/deimos/openssl/x509_vfy.d \
	src/deimos/openssl/x509v3.d \
	src/vibe/core/args.d \
	src/vibe/core/concurrency.d \
	src/vibe/core/connectionpool.d \
	src/vibe/core/core.d \
	src/vibe/core/driver.d \
	src/vibe/core/drivers/libev.d \
	src/vibe/core/drivers/libevent2.d \
	src/vibe/core/drivers/libevent2_tcp.d \
	src/vibe/core/drivers/threadedfile.d \
	src/vibe/core/drivers/win32.d \
	src/vibe/core/drivers/winrt.d \
	src/vibe/core/file.d \
	src/vibe/core/log.d \
	src/vibe/core/net.d \
	src/vibe/core/stream.d \
	src/vibe/core/sync.d \
	src/vibe/core/task.d \
	src/vibe/crypto/passwordhash.d \
	src/vibe/data/json.d \
	src/vibe/data/utils.d \
	src/vibe/http/auth/basic_auth.d \
	src/vibe/http/client.d \
	src/vibe/http/common.d \
	src/vibe/http/dist.d \
	src/vibe/http/fileserver.d \
	src/vibe/http/form.d \
	src/vibe/http/log.d \
	src/vibe/http/proxy.d \
	src/vibe/http/rest.d \
	src/vibe/http/restutil.d \
	src/vibe/http/router.d \
	src/vibe/http/server.d \
	src/vibe/http/session.d \
	src/vibe/http/status.d \
	src/vibe/http/websockets.d \
	src/vibe/inet/message.d \
	src/vibe/inet/mimetypes.d \
	src/vibe/inet/path.d \
	src/vibe/inet/url.d \
	src/vibe/inet/urltransfer.d \
	src/vibe/stream/base64.d \
	src/vibe/stream/counting.d \
	src/vibe/stream/memory.d \
	src/vibe/stream/operations.d \
	src/vibe/stream/ssl.d \
	src/vibe/stream/zlib.d \
	src/vibe/templ/diet.d \
	src/vibe/templ/parsertools.d \
	src/vibe/templ/utils.d \
	src/vibe/textfilter/html.d \
	src/vibe/textfilter/markdown.d \
	src/vibe/textfilter/urlencode.d \
	src/vibe/utils/array.d \
	src/vibe/utils/memory.d \
	src/vibe/utils/string.d \
	src/vibe/utils/validation.d \
	src/vibe/vibe.d \
	src/msgpack.d \
	src/msgpackrpc/common.d \
	src/msgpackrpc/client.d \
	src/msgpackrpc/server.d \
	src/msgpackrpc/transport/tcp.d \
	src/msgpackrpc/transport/udp.d \

target: $(LIB)

$(LIB):
	$(DMD) $(DFLAGS) -lib -of$(LIB) $(SRCS)

clean:
	rm -rf $(addprefix $(DOCDIR)/, $(DOCS)) $(LIB)

MAIN_FILE = "empty_msgpackrpc_unittest.d"

unittest:
	echo 'import msgpackrpc.server; void main(){}' > $(MAIN_FILE)
	$(DMD) $(DFLAGS) -unittest -of$(LIB) $(SRCS) -run $(MAIN_FILE)
	rm $(MAIN_FILE)

run_examples:
	echo example/* | xargs -n 1 dmd $(DFLAGS) $(SRCS) -Isrc -run
