typedef unsigned long Atom;

#define Bool int
#define Status int
#define Unsigned unsigned long
#define _Xconst const

#define PLAIN 7
#define SUFFIXED 0L
#define SHIFTED (1L << 15)
#define COMBINED ((1L << 0) | (1L << 3))
#define HEX_LONG 0x00ffL
#define CAST ((Atom) 31)
#define NEGATIVE (-2)
#define FLOATY (0.5f)
#define ALL_ONES ((unsigned long)~0L)
#define NAME "inputStyle"
#define UNUSED __attribute__((__unused__))

typedef struct {
    Bool send_event;
    Status *status;
} event;

Bool filter(event *ev, Bool *supported);
