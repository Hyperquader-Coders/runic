typedef struct Settings {
    int a;
} Settings;

typedef struct Item {
    int v;
} Item;

void app_apply(const Settings *settings);
void app_set_items(const Item *items, int n);
void app_get_item(Item **out);
void app_get_items(Item **items, int *n);
