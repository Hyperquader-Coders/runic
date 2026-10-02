typedef void *va_list;

void app_log(const char *fmt, ...);
void app_logv(const char *fmt, va_list args);
int app_count(int n);
