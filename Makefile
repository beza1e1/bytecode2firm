-include config.mak

BUILDDIR=build
GOAL = $(BUILDDIR)/bytecode2firm
CPPFLAGS = -I. $(LIBFIRM_CFLAGS) $(LIBOO_CFLAGS)
CFLAGS = -Wall -W -Wstrict-prototypes -Wmissing-prototypes -Wunreachable-code -Wlogical-op -Werror -O0 -g3 -std=c99 -pedantic
LFLAGS = $(LIBOO_LFLAGS) $(LIBFIRM_LFLAGS)
SOURCES = $(wildcard *.c) $(wildcard adt/*.c) $(wildcard driver/*.c)
DEPS = $(addprefix $(BUILDDIR)/, $(addsuffix .d, $(basename $(SOURCES))))
OBJECTS = $(addprefix $(BUILDDIR)/, $(addsuffix .o, $(basename $(SOURCES))))

Q ?= @

all: $(GOAL)

.phony: liboo
liboo:
	$(MAKE) -C $(LIBOO_HOME)
	$(MAKE) $(GOAL)

-include $(DEPS)

$(GOAL): $(OBJECTS)
	@echo '===> LD $@'
	$(Q)$(CC) -o $@ $^ $(LFLAGS)

$(BUILDDIR)/%.o: %.c $(BUILDDIR)
	@echo '===> CC $<'
	$(Q)#cparser $(CPPFLAGS) $(CFLAGS) -fsyntax-only $<
	$(Q)$(CC) $(CPPFLAGS) $(CFLAGS) -MD -MF $(addprefix $(BUILDDIR)/, $(addsuffix .d, $(basename $<))) -c -o $@ $<

$(BUILDDIR):
	$(Q)mkdir $(BUILDDIR)
	$(Q)mkdir $(BUILDDIR)/adt
	$(Q)mkdir $(BUILDDIR)/driver

clean:
	rm -rf $(OBJECTS) $(GOAL) $(DEPS)
	rm -rf $(BUILDDIR)
