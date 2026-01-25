#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <stdbool.h>
#include <limits.h>

#define MAX_LINE_LENGTH 2048
#define MAX_URL_LENGTH 512

typedef struct {
    char url[MAX_URL_LENGTH];
    int total_checks;
    int up_count;
    int down_count;
    long total_response_time;
    long min_response_time;
    long max_response_time;
    int state_changes;
    time_t first_seen;
    time_t last_seen;
} url_stats_t;

typedef struct {
    time_t timestamp;
    char url[MAX_URL_LENGTH];
    bool is_up;
    int status_code;
    long response_time;
} log_entry_t;

// Find or create stats for a URL
url_stats_t* find_or_create_stats(url_stats_t **stats, int *count, int *capacity, const char *url) {
    // Search for existing
    for (int i = 0; i < *count; i++) {
        if (strcmp((*stats)[i].url, url) == 0) {
            return &(*stats)[i];
        }
    }
    
    // Need to add new one
    if (*count >= *capacity) {
        *capacity *= 2;
        url_stats_t *new_stats = realloc(*stats, sizeof(url_stats_t) * (*capacity));
        if (!new_stats) {
            fprintf(stderr, "Failed to expand stats array\n");
            return NULL;
        }
        *stats = new_stats;
    }
    
    // Initialize new entry
    url_stats_t *new_entry = &(*stats)[*count];
    strncpy(new_entry->url, url, MAX_URL_LENGTH - 1);
    new_entry->url[MAX_URL_LENGTH - 1] = '\0';
    new_entry->total_checks = 0;
    new_entry->up_count = 0;
    new_entry->down_count = 0;
    new_entry->total_response_time = 0;
    new_entry->min_response_time = LONG_MAX;
    new_entry->max_response_time = 0;
    new_entry->state_changes = 0;
    new_entry->first_seen = 0;
    new_entry->last_seen = 0;
    
    (*count)++;
    return new_entry;
}

bool parse_log_line(const char *line, log_entry_t *entry) {
    char timestamp_str[64];
    char status_str[16];
    char state_change[16];
    
    // Parse CSV: timestamp,url,status,http_code,response_time_ms,state_change
    int fields = sscanf(line, "%63[^,],%511[^,],%15[^,],%d,%ld,%15s",
                       timestamp_str, entry->url, status_str, 
                       &entry->status_code, &entry->response_time, state_change);
    
    if (fields < 6) {
        return false;
    }
    
    entry->is_up = (strcmp(status_str, "UP") == 0);
    
    // Parse timestamp: YYYY-MM-DD HH:MM:SS
    struct tm tm = {0};
    if (strptime(timestamp_str, "%Y-%m-%d %H:%M:%S", &tm) != NULL) {
        entry->timestamp = mktime(&tm);
    } else {
        entry->timestamp = 0;
    }
    
    return true;
}

void print_summary(url_stats_t *stats, int count) {
    printf("\n");
    printf("========================================\n");
    printf("        LOG ANALYSIS SUMMARY            \n");
    printf("========================================\n\n");
    
    for (int i = 0; i < count; i++) {
        url_stats_t *s = &stats[i];
        
        printf("URL: %s\n", s->url);
        printf("  Total Checks: %d\n", s->total_checks);
        printf("  Up: %d | Down: %d\n", s->up_count, s->down_count);
        
        if (s->total_checks > 0) {
            double uptime_pct = (double)s->up_count / s->total_checks * 100.0;
            printf("  Uptime: %.2f%%\n", uptime_pct);
        }
        
        if (s->up_count > 0) {
            long avg = s->total_response_time / s->up_count;
            printf("  Response Time: avg=%ld ms, min=%ld ms, max=%ld ms\n",
                   avg, s->min_response_time, s->max_response_time);
        }
        
        printf("  State Changes: %d\n", s->state_changes);
        
        if (s->first_seen > 0) {
            char time_str[64];
            strftime(time_str, sizeof(time_str), "%Y-%m-%d %H:%M:%S", localtime(&s->first_seen));
            printf("  First Seen: %s\n", time_str);
        }
        
        if (s->last_seen > 0) {
            char time_str[64];
            strftime(time_str, sizeof(time_str), "%Y-%m-%d %H:%M:%S", localtime(&s->last_seen));
            printf("  Last Seen: %s\n", time_str);
            
            // Calculate monitoring duration
            long duration = s->last_seen - s->first_seen;
            long hours = duration / 3600;
            long minutes = (duration % 3600) / 60;
            printf("  Monitoring Duration: %ld hours, %ld minutes\n", hours, minutes);
        }
        
        printf("\n");
    }
}

void print_incidents(const char *log_file) {
    FILE *fp = fopen(log_file, "r");
    if (!fp) {
        perror("Failed to open log file");
        return;
    }
    
    char line[MAX_LINE_LENGTH];
    bool found_incidents = false;
    
    printf("========================================\n");
    printf("          DOWNTIME INCIDENTS            \n");
    printf("========================================\n\n");
    
    // Skip header
    if (fgets(line, sizeof(line), fp) == NULL) {
        fclose(fp);
        return;
    }
    
    while (fgets(line, sizeof(line), fp)) {
        log_entry_t entry;
        if (!parse_log_line(line, &entry)) {
            continue;
        }
        
        // Only show down events and state changes
        if (!entry.is_up || strstr(line, "YES")) {
            if (!found_incidents) {
                found_incidents = true;
            }
            
            char time_str[64];
            strftime(time_str, sizeof(time_str), "%Y-%m-%d %H:%M:%S", localtime(&entry.timestamp));
            
            if (!entry.is_up) {
                printf("[%s] %s - DOWN (HTTP %d)\n", time_str, entry.url, entry.status_code);
            } else if (strstr(line, "YES")) {
                printf("[%s] %s - RECOVERED (HTTP %d, %ld ms)\n", 
                       time_str, entry.url, entry.status_code, entry.response_time);
            }
        }
    }
    
    if (!found_incidents) {
        printf("No downtime incidents found. All systems operational!\n");
    }
    
    printf("\n");
    fclose(fp);
}

void print_recent_checks(const char *log_file, int num_entries) {
    FILE *fp = fopen(log_file, "r");
    if (!fp) {
        perror("Failed to open log file");
        return;
    }
    
    // Read all lines into memory (simple approach)
    char **lines = malloc(sizeof(char*) * 1000);
    int line_count = 0;
    char line[MAX_LINE_LENGTH];
    
    // Skip header
    if (fgets(line, sizeof(line), fp) == NULL) {
        free(lines);
        fclose(fp);
        return;
    }
    
    while (fgets(line, sizeof(line), fp) && line_count < 1000) {
        lines[line_count] = strdup(line);
        line_count++;
    }
    fclose(fp);
    
    printf("========================================\n");
    printf("       RECENT CHECKS (Last %d)          \n", num_entries);
    printf("========================================\n\n");
    
    // Print last N entries
    int start = line_count - num_entries;
    if (start < 0) start = 0;
    
    for (int i = start; i < line_count; i++) {
        log_entry_t entry;
        if (parse_log_line(lines[i], &entry)) {
            char time_str[64];
            strftime(time_str, sizeof(time_str), "%Y-%m-%d %H:%M:%S", localtime(&entry.timestamp));
            
            printf("[%s] %s - %s", time_str, entry.url, entry.is_up ? "UP" : "DOWN");
            if (entry.is_up) {
                printf(" (HTTP %d, %ld ms)", entry.status_code, entry.response_time);
            } else {
                printf(" (HTTP %d)", entry.status_code);
            }
            printf("\n");
        }
    }
    
    printf("\n");
    
    // Cleanup
    for (int i = 0; i < line_count; i++) {
        free(lines[i]);
    }
    free(lines);
}

int main(int argc, char *argv[]) {
    const char *log_file = "upmon.log";
    
    if (argc > 1) {
        log_file = argv[1];
    }
    
    printf("Analyzing log file: %s\n", log_file);
    
    FILE *fp = fopen(log_file, "r");
    if (!fp) {
        perror("Failed to open log file");
        return 1;
    }
    
    // Initialize stats
    int capacity = 10;
    int count = 0;
    url_stats_t *stats = malloc(sizeof(url_stats_t) * capacity);
    if (!stats) {
        fclose(fp);
        return 1;
    }
    
    char line[MAX_LINE_LENGTH];
    
    // Skip header line
    if (fgets(line, sizeof(line), fp) == NULL) {
        fprintf(stderr, "Empty log file\n");
        free(stats);
        fclose(fp);
        return 1;
    }
    
    // Process each log entry
    while (fgets(line, sizeof(line), fp)) {
        log_entry_t entry;
        if (!parse_log_line(line, &entry)) {
            continue;
        }
        
        url_stats_t *s = find_or_create_stats(&stats, &count, &capacity, entry.url);
        if (!s) {
            break;
        }
        
        s->total_checks++;
        
        if (entry.is_up) {
            s->up_count++;
            s->total_response_time += entry.response_time;
            
            if (entry.response_time < s->min_response_time) {
                s->min_response_time = entry.response_time;
            }
            if (entry.response_time > s->max_response_time) {
                s->max_response_time = entry.response_time;
            }
        } else {
            s->down_count++;
        }
        
        // Check for state change
        if (strstr(line, ",YES")) {
            s->state_changes++;
        }
        
        // Track time range
        if (s->first_seen == 0 || entry.timestamp < s->first_seen) {
            s->first_seen = entry.timestamp;
        }
        if (entry.timestamp > s->last_seen) {
            s->last_seen = entry.timestamp;
        }
    }
    
    fclose(fp);
    
    // Print analysis
    print_summary(stats, count);
    print_incidents(log_file);
    print_recent_checks(log_file, 10);
    
    // Cleanup
    free(stats);
    
    return 0;
}
