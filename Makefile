ERTS_INCLUDE_DIR := $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
PRIV_DIR = $(MIX_APP_PATH)/priv
NIF_DEMO_SO = $(PRIV_DIR)/nif_demo.so
NIF_MAT_MUL_SO = $(PRIV_DIR)/nif_mat_mul.so
CFLAGS = -fPIC -I$(ERTS_INCLUDE_DIR) -O3
LDFLAGS = -shared -dynamiclib -undefined dynamic_lookup

ifeq ($(shell uname -s), Darwin)
    LDFLAGS += -flat_namespace -undefined suppress
endif

all: $(NIF_DEMO_SO) $(NIF_MAT_MUL_SO)

$(NIF_DEMO_SO): native/nif_demo.c
	mkdir -p $(PRIV_DIR)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

$(NIF_MAT_MUL_SO): native/nif_mat_mul.c
	mkdir -p $(PRIV_DIR)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

clean:
	rm -f $(NIF_DEMO_SO) $(NIF_MAT_MUL_SO)

.PHONY: all clean