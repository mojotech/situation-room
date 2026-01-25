#include <stdio.h>
#include <time.h>
#include "monitor.h"

static FILE *log_fp = NULL;

bool log_init(const char *log_file) {
    log_fp = fopen(log_file, "a");
    if (!log_fp) {
        perror("Failed to open log file");
        return false;
    }
    
    // Write header if file is new/empty
    fseek(log_fp, 0, SEEK_END);
    if (ftell(log_fp) == 0) {
        fprintf(log_fp, "timestamp,url,status,http_code,response_time_ms,state_change\n");
    }
    
    return true;
}

void log_check(const monitor_target_t *target, const http_result_t *result, bool state_changed) {
    if (!log_fp) return;
    
    time_t now = time(NULL);
    char time_str[64];
    strftime(time_str, sizeof(time_str), "%Y-%m-%d %H:%M:%S", localtime(&now));
    
    fprintf(log_fp, "%s,%s,%s,%d,%ld,%s\n",
            time_str,
            target->url,
            result->success ? "UP" : "DOWN",
            result->status_code,
            result->response_time_ms,
            state_changed ? "YES" : "NO");
    
    fflush(log_fp);  // Ensure it's written immediately
}

void log_close(void) {
    if (log_fp) {
        fclose(log_fp);
        log_fp = NULL;
    }
}

void print_statistics(const monitor_target_t *target) {
    printf("\n--- Statistics for %s ---\n", target->url);
    printf("  Total Checks: %d\n", target->total_checks);
    printf("  Successful: %d\n", target->successful_checks);
    printf("  Failed: %d\n", target->failed_checks);
    
    if (target->total_checks > 0) {
        double uptime_pct = (double)target->successful_checks / target->total_checks * 100.0;
        printf("  Uptime: %.2f%%\n", uptime_pct);
    }
    
    if (target->successful_checks > 0) {
        long avg_response = target->total_response_time / target->successful_checks;
        printf("  Avg Response Time: %ld ms\n", avg_response);
    }
    
    if (target->last_up_time > 0) {
        char time_str[64];
        strftime(time_str, sizeof(time_str), "%Y-%m-%d %H:%M:%S", localtime(&target->last_up_time));
        printf("  Last Seen Up: %s\n", time_str);
    }
    
    if (target->last_down_time > 0) {
        char time_str[64];
        strftime(time_str, sizeof(time_str), "%Y-%m-%d %H:%M:%S", localtime(&target->last_down_time));
        printf("  Last Seen Down: %s\n", time_str);
        
        if (!target->is_up) {
            time_t now = time(NULL);
            long down_duration = now - target->last_down_time;
            printf("  Currently Down For: %ld seconds\n", down_duration);
        }
    }
    
    printf("\n");
}

void print_all_statistics(const monitor_list_t *monitors) {
    printf("\n");
    printf("========================================\n");
    printf("           MONITORING STATISTICS        \n");
    printf("========================================\n");
    
    for (int i = 0; i < monitors->count; i++) {
        print_statistics(&monitors->targets[i]);
    }
}
