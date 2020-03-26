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


int main(int argc, char* argv[]) {
    if (argc < 3) {
      fprintf(stderr, "Not enough arguments\n");
      return 1;
    }
    vector<vector<char*> > outputs;
    outputs.resize(3);

    char* input_line = NULL;

    size_t n=0;
    while(getline(&input_line, &n, stdin) >= 0) {
        n = 0;
        char *token, *directory, *command;
        auto last_start = input_line;
        while(*input_line != 0 && *input_line != ',') {
            if (*input_line == ' ') last_start = input_line + 1;
            ++input_line;
        }
        BAILOUT;
        *input_line=0;
        token=last_start;
        if (skip_over_column_and_found_end_of_string(input_line)) continue;
        if (skip_over_column_and_found_end_of_string(input_line)) continue;
        if (skip_over_column_and_found_end_of_string(input_line)) continue;
        last_start = input_line;
        if (skip_over_column_and_found_end_of_string(input_line)) continue;
        directory=last_start;
        *input_line=0;
        command=input_line+1;
        input_line = NULL;
        if (strcmp(token, argv[1]) == 0) {
            outputs[2].push_back(command);
        } else if (is_directory(directory, argv[2])) {
            outputs[1].push_back(command);
        } else {
            fputs(command, stdout);
        }

    }
    for (unsigned int i=0;i<outputs.size();i++) {
        for (unsigned int j=0;j<outputs[i].size();j++) {
           fputs(outputs[i][j], stdout);
        }
    }
    return 0;
}
