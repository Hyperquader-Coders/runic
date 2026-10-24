int query_keymap(void *display, char keys_return[32]);
void matrix(int m[2][3]);
void names(const char *list[]);
typedef void (*keymap_cb)(char keys[32]);
