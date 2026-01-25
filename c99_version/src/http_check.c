#include <stdio.h>
#include <curl/curl.h>
#include "monitor.h"

// Callback to discard response body (we only care about headers)
static size_t write_callback(void *contents, size_t size, size_t nmemb, void *userp) {
    return size * nmemb;  // Discard data
}

http_result_t http_check(const char *url, int timeout_ms) {
    http_result_t result = {0, 0, false};
    CURL *curl;
    CURLcode res;
    
    curl = curl_easy_init();
    if (!curl) {
        fprintf(stderr, "Failed to initialize curl\n");
        return result;
    }
    
    // Set options
    curl_easy_setopt(curl, CURLOPT_URL, url);
    curl_easy_setopt(curl, CURLOPT_NOBODY, 1L);  // HEAD request
    curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
    curl_easy_setopt(curl, CURLOPT_TIMEOUT_MS, (long)timeout_ms);
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_callback);
    
    // Perform request
    struct timeval start, end;
    gettimeofday(&start, NULL);
    
    res = curl_easy_perform(curl);
    
    gettimeofday(&end, NULL);
    result.response_time_ms = (end.tv_sec - start.tv_sec) * 1000 + 
                              (end.tv_usec - start.tv_usec) / 1000;
    
    if (res == CURLE_OK) {
        long status;
        curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &status);
        result.status_code = (int)status;
        result.success = (status >= 200 && status < 400);
    } else {
        fprintf(stderr, "curl_easy_perform() failed: %s\n", curl_easy_strerror(res));
        result.success = false;
    }
    
    curl_easy_cleanup(curl);
    return result;
}
