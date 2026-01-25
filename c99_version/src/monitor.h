#ifndef MONITOR_H
#define MONITOR_H

#include <time.h>
#include <stdbool.h>

typedef struct {
    char *url;
    int interval_seconds;
    int timeout_ms;
    bool is_up;
    time_t last_check;
    long response_time_ms;
    int last_status_code;
    
    // Statistics
    int total_checks;
    int successful_checks;
    int failed_checks;
    long total_response_time;
    time_t last_down_time;
    time_t last_up_time;
    long total_downtime_seconds;
} monitor_target_t;

typedef struct {
    monitor_target_t *targets;
    int count;
    int capacity;
} monitor_list_t;

typedef struct {
    int status_code;
    long response_time_ms;
    bool success;
} http_result_t;

// Function declarations
http_result_t http_check(const char *url, int timeout_ms);
void print_result(const monitor_target_t *target, const http_result_t *result);

// Config functions
monitor_list_t* load_config(const char *filename);
void free_monitor_list(monitor_list_t *list);

// Logging functions
bool log_init(const char *log_file);
void log_check(const monitor_target_t *target, const http_result_t *result, bool state_changed);
void log_close(void);
void print_statistics(const monitor_target_t *target);
void print_all_statistics(const monitor_list_t *monitors);

#endif
