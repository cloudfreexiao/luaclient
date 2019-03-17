include ./platform.mk

LUA_INC ?= lua/src

LUA_CLIB_PATH ?= luaclib/

TERMFX_INC ?= lualib-src/termfx
LUASOCKET_INC ?= lualib-src/luasocket

TERMFX_SO_NAME = termfx.so
LUASOCKET_NAME = socket.so
MIME_NAME = mime.so

TERMFX_SO      			= $(LUA_CLIB_PATH)$(TERMFX_SO_NAME)
LUASOCKET_SO 		 	= $(LUA_CLIB_PATH)$(LUASOCKET_NAME)
MIME_SO 		 		= $(LUA_CLIB_PATH)$(MIME_NAME)
CRYPT_SO 		 		= $(LUA_CLIB_PATH)crypt.so


all: $(TERMFX_SO) \
	$(LUASOCKET_SO) $(CRYPT_SO) \

#####################################################

ifeq ($(PLAT),macosx)
	OS = Darwin
else
	OS = linux
endif

$(TERMFX_SO) : | $(LUA_CLIB_PATH)
	cd $(TERMFX_INC) && $(MAKE) OS=$(OS) LUA_INCLUDE_DIR=$(LUA_INC)
	cp -f $(TERMFX_INC)/$(TERMFX_SO_NAME) $@

$(LUASOCKET_SO) : $(LUA_CLIB_PATH)
	PLAT=$(PLAT) DEBUG=NODEBUG LUAV=5.3 LUAINC_$(PLAT)=../../../$(LUA_INC) $(MAKE) -C $(LUASOCKET_INC)
	cp -f $(LUASOCKET_INC)/src/socket-3.0-rc1.so $@
	cp -f $(LUASOCKET_INC)/src/mime-1.0.3.so $(MIME_SO)


$(CRYPT_SO) : lualib-src/crypt/lua-crypt.c lualib-src/crypt/lsha1.c | $(LUA_CLIB_PATH)
	$(CC) $(CFLAGS) $(SHARED) $^ -o $@ -I$(LUA_INC)

#####################################################

client:
	./lua/src/lua ./client.lua

clean:
	rm -f $(LUA_CLIB_PATH)*.so

.PHONY: all clean
