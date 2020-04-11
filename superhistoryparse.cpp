#include <cstring>
#include <cstdio>
#include <vector>
#include <iostream>
#include <sys/mman.h>
#include <fcntl.h>
#include <sys/stat.h>


using namespace std;

inline bool skip_over_column_and_found_end_of_string(char* &input_line) {
  for(;*input_line != '\n' && *input_line != ','; ++input_line);
  if (*input_line == '\n') {
    return true;
  }
  ++input_line;
  return false;
}

inline bool skip_over_column_and_check_for_directory_and_found_end_of_string(char* directory, char* &input_line, bool &found_directory) {
  found_directory = true;
  for(;*input_line != '\n' && *input_line != ','; ++input_line, ++directory) {
    if (*directory == 0 || *directory != *input_line) break;
  }
  if (*directory == 0 && *input_line == ',') {
    found_directory=true;
  } else if (*directory==0 && *input_line == ' ') {
    ++input_line;
    if (*input_line == '-') {
      ++input_line;
      if (*input_line == '>') {
        ++input_line;
        if (*input_line == ' ') {
          ++input_line;
          found_directory=true;
        } else {
          found_directory=false;
        }
      } else {
        found_directory=false;
      }
    } else {
      found_directory=false;
    }
  } else {
    found_directory=false;
  }
  while(*input_line != '\n' && *input_line != ',') ++input_line;
  if (*input_line == ',') {
    ++input_line;
    return false;
  }
  ++input_line;
  return true;
}

inline bool skip_over_column_and_check_for_token_at_the_and_and_found_end_of_string(char* token, char* &input_line, bool &found_token) {
  char *cmp = token;
  found_token=true;
  for(;*input_line != '\n' && *input_line != ','; ++input_line) {
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
    ++input_line;
    return false;
  }
  ++input_line;
  return true;
}

char* end_of_input;

const size_t HASHTABLE_SIZE = 1024*1024*8 / 32;
const unsigned int MODULUS = 8388593;
const unsigned int MULT = 199;

inline unsigned int hash_char(unsigned int state, unsigned int c) {
  return (state * MULT + c) % MODULUS;
}
unsigned int mem[HASHTABLE_SIZE];
inline unsigned int lookup(unsigned int hash) {
  return (mem[(hash)>>5]&(1<<((hash)&31)));
}
inline void set(unsigned int hash) {
  mem[(hash)>>5] |= 1 << ((hash)&31);
}

typedef struct {
  char*str;
  size_t len;
  unsigned int hsh;
} my_string;

inline unsigned int hash_str(const my_string &str) {
  unsigned int state = 0;
  for (unsigned int i=0;i<str.len; i++) {
    state = hash_char(state, str.str[i]);
  }
  return state;
}



int main(int argc, char* argv[]) {
    if (argc < 4) {
      fprintf(stderr, "Not enough arguments\n");
      return 1;
    }
    vector<my_string> out;
    vector<my_string> o1, o2;
    o1.reserve(1024);
    o2.reserve(1024);
    out.reserve(200000);
    my_string cmd;

    struct stat st;
    stat(argv[3], &st);
    off_t size = st.st_size;
    auto input = open(argv[3], O_RDONLY);

    char* input_line=(char*) mmap(NULL, size, PROT_READ, MAP_PRIVATE, input, 0);
    end_of_input = input_line+ size;


    while(input_line < end_of_input) {
        bool found_token;
        bool found_directory;
        if (skip_over_column_and_check_for_token_at_the_and_and_found_end_of_string(argv[1], input_line, found_token)) continue;
        if (skip_over_column_and_found_end_of_string(input_line)) continue;
        if (skip_over_column_and_found_end_of_string(input_line)) continue;
        if (skip_over_column_and_found_end_of_string(input_line)) continue;
        if (skip_over_column_and_check_for_directory_and_found_end_of_string(argv[2], input_line, found_directory)) continue;
        cmd.str = input_line;
        unsigned int hsh = 0;
        while(input_line < end_of_input && *input_line != '\n') {hsh = hash_char(hsh, *input_line);++input_line;}
        cmd.len = input_line - cmd.str;
        cmd.hsh = hsh;
        input_line += 1;

        if (found_token) {
            o2.push_back(cmd);
        } else if (found_directory) {
            o1.push_back(cmd);
        } else {
            out.push_back(cmd);
        }

    }
    auto o1s = o1.size();
    for (unsigned int j=0;j<o1s;j++) {
        out.push_back(o1[j]);
    }
    auto o2s = o2.size();
    for (unsigned int j=0;j<o2s;j++) {
        out.push_back(o2[j]);
    }
    for (int j = out.size()-1; j >= 0; --j) {
      auto &cmd = out[j];
      if (lookup(cmd.hsh) == 0) {
        set(cmd.hsh);
        fwrite_unlocked(cmd.str, 1, cmd.len, stdout);
        putc_unlocked(0, stdout);
      }

    }
    return 0;
}
