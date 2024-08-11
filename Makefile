ERTS_INCLUDE_DIR := $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
PRIV_DIR = $(MIX_APP_PATH)/priv
NIF_SO = $(PRIV_DIR)/nif_demo.so

CFLAGS = -fPIC -I$(ERTS_INCLUDE_DIR)
LDFLAGS = -dynamiclib -undefined dynamic_lookup

ifeq ($(shell uname -s), Darwin)
    LDFLAGS += -flat_namespace -undefined suppress
endif

$(NIF_SO): native/nif_demo.c
	mkdir -p $(PRIV_DIR)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(NIF_SO) native/nif_demo.c

all: $(NIF_SO)

clean:
	rm -f $(NIF_SO)
