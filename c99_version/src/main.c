#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <signal.h>
#include <unistd.h>
#include <curl/curl.h>
#include "monitor.h"

// Global flag for graceful shutdown
static volatile sig_atomic_t keep_running = 1;
static volatile sig_atomic_t show_stats = 0;

void signal_handler(int signum) {
    if (signum == SIGINT || signum == SIGTERM) {
        keep_running = 0;
        printf("\n\nShutdown signal received, finishing current checks...\n");
    } else if (signum == SIGUSR1) {
        show_stats = 1;  // Print stats on SIGUSR1
    }
}

void print_result(const monitor_target_t *target, const http_result_t *result) {
    time_t now = time(NULL);
    char time_str[64];
    strftime(time_str, sizeof(time_str), "%Y-%m-%d %H:%M:%S", localtime(&now));
    
    printf("[%s] %s\n", time_str, target->url);
    if (result->success) {
        printf("  Status: UP (HTTP %d)\n", result->status_code);
        printf("  Response Time: %ld ms\n", result->response_time_ms);
    } else {
        printf("  Status: DOWN\n");
    }
    printf("\n");
}

void check_target(monitor_target_t *target) {
    http_result_t result = http_check(target->url, target->timeout_ms);
    
    // Track statistics
    time_t now = time(NULL);
    bool was_up = target->is_up;
    bool state_changed = false;
    
    target->total_checks++;
    target->last_check = now;
    target->last_status_code = result.status_code;
    target->response_time_ms = result.response_time_ms;
    
    if (result.success) {
        target->successful_checks++;
        target->total_response_time += result.response_time_ms;
        target->is_up = true;
        
        if (!was_up) {
            // Site came back up
            state_changed = true;
            target->last_up_time = now;
            if (target->last_down_time > 0) {
                target->total_downtime_seconds += (now - target->last_down_time);
            }
            printf("*** RECOVERY: Site came back UP ***\n");
        }
    } else {
        target->failed_checks++;
        target->is_up = false;
        
        if (was_up || target->last_down_time == 0) {
            // Site went down
            state_changed = true;
            target->last_down_time = now;
            printf("*** ALERT: Site went DOWN ***\n");
        }
    }
    
    print_result(target, &result);
    log_check(target, &result, state_changed);
}

int main(int argc, char *argv[]) {
    const char *config_file = "config.txt";
    const char *log_file = "situation-room.log";
    
    if (argc > 1) {
        config_file = argv[1];
    }
    if (argc > 2) {
        log_file = argv[2];
    }
    
    // Set up signal handlers
    signal(SIGINT, signal_handler);
    signal(SIGTERM, signal_handler);
    signal(SIGUSR1, signal_handler);  // For stats on demand
    
    // Load config
    monitor_list_t *monitors = load_config(config_file);
    if (!monitors || monitors->count == 0) {
        fprintf(stderr, "No targets to monitor\n");
        return 1;
    }
    
    // Initialize logging
    if (!log_init(log_file)) {
        fprintf(stderr, "Warning: Logging disabled\n");
    } else {
        printf("Logging to: %s\n", log_file);
    }
    
    // Initialize curl globally
    curl_global_init(CURL_GLOBAL_DEFAULT);
    
    // Perform initial checks
    printf("Starting situation-room - monitoring %d targets\n", monitors->count);
    printf("Press Ctrl+C to stop, send SIGUSR1 for stats (kill -USR1 %d)\n\n", getpid());
    printf("=== Initial Checks ===\n\n");
    
    for (int i = 0; i < monitors->count; i++) {
        check_target(&monitors->targets[i]);
    }
    
    // Main monitoring loop
    printf("=== Continuous Monitoring Started ===\n\n");
    
    while (keep_running) {
        // Check if stats were requested
        if (show_stats) {
            print_all_statistics(monitors);
            show_stats = 0;
        }
        
        time_t now = time(NULL);
        time_t next_check = now + 3600;
        
        // Check each target if it's due
        for (int i = 0; i < monitors->count; i++) {
            monitor_target_t *target = &monitors->targets[i];
            time_t due_time = target->last_check + target->interval_seconds;
            
            if (now >= due_time) {
                check_target(target);
                due_time = time(NULL) + target->interval_seconds;
            }
            
            // Track the next upcoming check time
            if (due_time < next_check) {
                next_check = due_time;
            }
        }
        
        // Sleep until next check (or max 5 seconds)
        if (keep_running) {
            time_t sleep_time = next_check - time(NULL);
            if (sleep_time > 5) {
                sleep_time = 5;
            }
            if (sleep_time > 0) {
                sleep(sleep_time);
            }
        }
    }
    
    // Print final statistics before shutdown
    print_all_statistics(monitors);
    
    // Cleanup
    printf("\nShutting down...\n");
    log_close();
    curl_global_cleanup();
    free_monitor_list(monitors);
    
    printf("Goodbye!\n");
    return 0;
}
