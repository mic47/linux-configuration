#include <cstring>
#include <cstdio>
#include <vector>
#include <iostream>

using namespace std;

inline bool is_directory(char* directory, char* current_path) {
    for(;*directory != 0 && *current_path != 0 && *directory == *current_path; directory++, current_path++);
    if (*current_path != 0) return false;
    if (*directory == 0) return true;
    return strncmp(directory, " -> ", 4) == 0;
}

#define BAILOUT if(*input_line==0){input_line=NULL;continue;}

inline bool skip_over_column_and_found_end_of_string(char* &input_line) {
  for(;*input_line != 0 && *input_line != ','; ++input_line);
  if (*input_line == 0) {
    input_line = NULL;
    return true;
  }
  ++input_line;
  return false;
}

inline bool skip_over_column_and_check_for_token_at_the_and_and_found_end_of_string(char* token, char* &input_line, bool &found_token) {
  char *cmp = token;
  found_token=true;
  for(;*input_line != 0 && *input_line != ','; ++input_line) {
    if (*input_line == ' ') {
      cmp=token;
      found_token=true;
      continue;
    }
    if (*cmp == *input_line && *cmp != 0) {
      ++cmp;
    } else {
      found_token=false;
    }
  }
  if (*input_line == ',') {
    found_token &= *cmp == 0;
    return false;
  }
  input_line = NULL;
  return true;
}


int main(int argc, char* argv[]) {
    if (argc < 3) {
      fprintf(stderr, "Not enough arguments\n");
      return 1;
    }
    vector<char*> o1, o2;

    char* input_line = NULL;
    auto input = fopen(argv[3], "r");

    size_t n=0;
    while(getline(&input_line, &n, input) >= 0) {
        n = 0;
        char *directory, *command;
        auto last_start = input_line;
        bool found_token;
        if (skip_over_column_and_check_for_token_at_the_and_and_found_end_of_string(argv[1], input_line, found_token)) continue;
        *input_line=0;
        ++input_line;
        if (skip_over_column_and_found_end_of_string(input_line)) continue;
        if (skip_over_column_and_found_end_of_string(input_line)) continue;
        if (skip_over_column_and_found_end_of_string(input_line)) continue;
        last_start = input_line;
        if (skip_over_column_and_found_end_of_string(input_line)) continue;
        directory=last_start;
        *(input_line-1)=0;
        command=input_line;
        input_line = NULL;
        if (found_token) {
            o2.push_back(command);
        } else if (is_directory(directory, argv[2])) {
            o1.push_back(command);
        } else {
            fputs_unlocked(command, stdout);
        }

    }
    for (unsigned int j=0;j<o1.size();j++) {
       fputs_unlocked(o1[j], stdout);
    }
    for (unsigned int j=0;j<o2.size();j++) {
       fputs_unlocked(o2[j], stdout);
    }
    return 0;
}
