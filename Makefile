SUB_TARGETS := ppp rp-pppoe

.PHONY: all
all: $(SUB_TARGETS)

.PHONY: $(SUB_TARGETS)
rp-pppoe: ppp
$(SUB_TARGETS):
	$(MAKE) -C $@
