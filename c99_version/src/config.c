#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "monitor.h"

#define INITIAL_CAPACITY 10
#define MAX_LINE_LENGTH 1024

monitor_list_t* load_config(const char *filename) {
    FILE *fp = fopen(filename, "r");
    if (!fp) {
        perror("Failed to open config file");
        return NULL;
    }
    
    monitor_list_t *list = malloc(sizeof(monitor_list_t));
    if (!list) {
        fclose(fp);
        return NULL;
    }
    
    list->capacity = INITIAL_CAPACITY;
    list->count = 0;
    list->targets = malloc(sizeof(monitor_target_t) * list->capacity);
    if (!list->targets) {
        free(list);
        fclose(fp);
        return NULL;
    }
    
    char line[MAX_LINE_LENGTH];
    int line_num = 0;
    
    while (fgets(line, sizeof(line), fp)) {
        line_num++;
        
        // Remove newline
        line[strcspn(line, "\n")] = 0;
        
        // Skip empty lines and comments
        if (line[0] == '\0' || line[0] == '#') {
            continue;
        }
        
        // Parse CSV: url,interval,timeout
        char *url = strtok(line, ",");
        char *interval_str = strtok(NULL, ",");
        char *timeout_str = strtok(NULL, ",");
        
        if (!url || !interval_str || !timeout_str) {
            fprintf(stderr, "Warning: Invalid format on line %d, skipping\n", line_num);
            continue;
        }
        
        // Expand array if needed
        if (list->count >= list->capacity) {
            list->capacity *= 2;
            monitor_target_t *new_targets = realloc(list->targets, 
                sizeof(monitor_target_t) * list->capacity);
            if (!new_targets) {
                fprintf(stderr, "Failed to expand target list\n");
                break;
            }
            list->targets = new_targets;
        }
        
        // Add target
        monitor_target_t *target = &list->targets[list->count];
        target->url = strdup(url);
        target->interval_seconds = atoi(interval_str);
        target->timeout_ms = atoi(timeout_str);
        target->is_up = false;
        target->last_check = 0;
        target->response_time_ms = 0;
        target->last_status_code = 0;
        
        // Initialize statistics
        target->total_checks = 0;
        target->successful_checks = 0;
        target->failed_checks = 0;
        target->total_response_time = 0;
        target->last_down_time = 0;
        target->last_up_time = 0;
        target->total_downtime_seconds = 0;
        
        list->count++;
    }
    
    fclose(fp);
    printf("Loaded %d targets from %s\n\n", list->count, filename);
    return list;
}

void free_monitor_list(monitor_list_t *list) {
    if (!list) return;
    
    for (int i = 0; i < list->count; i++) {
        free(list->targets[i].url);
    }
    free(list->targets);
    free(list);
}
