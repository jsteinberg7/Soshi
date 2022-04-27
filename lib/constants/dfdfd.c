#include <stdlib.h>
#include <sys/types.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>
#include "fakefile-datastructure.h"
#include "safe-fork.h"
#include "split.h"
#include "memory-checking.h"
#include "errno.h"
#include <sys/wait.h>
/*
Yuvan Sundrani
UID: 117095609
Section: 0207
I pledge on my honor I have nto gven nore recieved any assistance on this 
project
*/

/*
The main point of this file is to contain functions that similate the 
action, dependencies, and the target for further use
 */

/*
This functions main point is to check whether a rule exists in a fakefile
*/
int exists(const char filename[]) {
struct stat *buf = malloc(sizeof(struct stat)) ;
int result;
if (filename == NULL){/* checking parameters */
  return 0;
 }
 
 errno = 0;
 result = stat(filename, buf);
 
 if (result == -1){
   if(errno == ENOENT){
     return 0;
   }
    return 1;
 }

 else {
   return 1;
 } 
 
 return 0;
}

/*
  The main point of this function is to check whether two different
  file names are older, or which one is older
*/
int is_older(const char filename[], const char filename2[]){
  
  int file1_age, file2_age;
  int file_exist;
  struct stat *buf_temp;
  buf_temp = malloc(sizeof(struct stat));
  
  if (filename == NULL || filename == NULL || filename2 == NULL){
      return 0;
  }
  
  else {
    
    file_exist = exists(filename);/* Chekcing existence*/
    
    if (file_exist == 0){
      return 0;
    }
    
    file_exist = exists(filename2);
    
    if (file_exist == 0){
      return 0;
    }
    
    stat(filename, buf_temp);
    file1_age = buf_temp -> st_mtime;
    
    stat(filename2, buf_temp);
    file2_age = buf_temp -> st_mtime;
    
    
    if (file1_age < file2_age){
      
      return 1;
    }
  }
  
  return 0;
}

/*
  The main point of this fucntion is to "initialize" or really 
  prep the fakefile for reading. 
  it is a linked list that adds "rules" as elements
*/
Fakefile *read_fakefile(const char filename[]){
  
  struct Fakefile *fakefile;
  
  int does_file_exist = 1;
  struct Rule *temp_rule;
  int action_line_flag = 0;
  FILE* fh;
  char buffer[500];
  int rule_finished_2 = 0;
  int rule_finished_1 = 0;
  
  
  if (filename == NULL || does_file_exist == 0){
    return NULL;
  }/*checking parameters */
  
  
  fakefile = malloc(sizeof(struct Fakefile));
  temp_rule = malloc(sizeof(struct Rule));
  
  fakefile -> root = NULL;
  fakefile -> next = NULL;
  fakefile -> curr = fakefile -> root;
  
  temp_rule -> target = NULL;
  temp_rule -> dependencies = NULL;
  temp_rule -> dependency_count = 0;
  temp_rule -> action_line = NULL;
  /* Setting vars to be used */
  
  fh = fopen(filename, "r");
  
  while (!feof(fh)){
    
    if (fgets(buffer, 1000, fh) != NULL){
      
      char **split_line;
      
      split_line = split(buffer);
      
	if (split_line[0] == NULL || strcmp(split_line[0], "\n") == 0){
	  rule_finished_2 = 0;
	  rule_finished_1 = 0;
	  
	}

	else if (action_line_flag == 1){ 
	  temp_rule -> action_line = split_line;
	  action_line_flag = 0;
	  rule_finished_2 = 1;	  
	}
	
	else {
	  temp_rule -> target = split_line[0];
	  temp_rule -> dependencies = split_line;
	  action_line_flag = 1;
	    rule_finished_1 = 1;	    
	}
    }

    if (rule_finished_2 == 1 && rule_finished_1 == 1) {

      if ((fakefile -> root) == NULL){
	    fakefile -> root  = temp_rule;
	    fakefile -> curr = fakefile -> root;
	    fakefile -> next = fakefile -> curr -> next_elem;
      }

      else {
	fakefile -> curr -> next_elem = temp_rule;
	fakefile -> curr = fakefile -> curr -> next_elem;
	  fakefile -> next = fakefile -> curr -> next_elem;
      }
      
	temp_rule = malloc(sizeof(struct Rule));
	temp_rule -> target = NULL;
	temp_rule -> dependencies = NULL;
	temp_rule -> dependency_count = 0;
	temp_rule -> action_line = NULL;
	rule_finished_2 = 0;
	rule_finished_1 = 1;	
    }
  }
  
  return fakefile;
}

/*
The main point of this function is to look up a target in the fakefile 
system
*/
int lookup_target(Fakefile *const fakefile, const char target_name[]){
  
  int does_exist = exists(target_name);
  int target_count = 0;
  
  if (fakefile == NULL || target_name == NULL || does_exist == 0){
    return -1;
  }
  
  else {
    
    fakefile -> curr = fakefile -> root;

     if (fakefile -> curr -> next_elem == NULL){
       
      if (strcmp(fakefile -> curr -> target, target_name) == 0){
	
	return target_count;	
      }
     }
     
     else {
       
       while (fakefile -> curr -> next_elem != NULL){
	 if (strcmp(fakefile -> curr -> target, target_name) == 0){
	   return target_count;
	 }
	 target_count ++;
	 fakefile -> curr = fakefile -> curr -> next_elem;
	 fakefile -> next = fakefile -> next;
       }
       
       if (fakefile -> curr -> next_elem == NULL){

	 if (strcmp(fakefile -> curr -> target, target_name) == 0){
	   return target_count;	
	 }
       }
     }
     
     return -1;
  }
  return -1;
}

/*
  The main point of this function is to print the action line a designated 
  rule based on its rule number
*/
void print_action(Fakefile *const fakefile, int rule_num){
  int i;
  
  if (fakefile == NULL || rule_num < 0){
    return;
  }
  
  fakefile -> curr = fakefile -> root;
  
  for(i = 0; i < rule_num; i++){
    
    fakefile -> curr = fakefile -> curr -> next_elem;
  }
  
  while (*(fakefile -> curr -> action_line) != NULL){
    printf("%s", *(fakefile -> curr -> action_line)++);
    if(*(fakefile -> curr -> action_line) != NULL){
      
      printf(" ");
    } 
  }
  printf("\n");
}


/*
  The main point of this function is to print the entire fakefile system
*/
void print_fakefile(Fakefile *const fakefile){
  
  fakefile -> curr = fakefile-> root;
  
  if (fakefile == NULL){
    return;
  }
  else {
    
    if (fakefile -> curr == NULL){
      printf("curr is null\n");
      return;
    }

    else {
      
      while (fakefile -> curr != NULL){
	
	printf("%s: ", fakefile -> curr -> target);
	(fakefile -> curr -> dependencies)++;
	while (*(fakefile -> curr -> dependencies) != NULL){
	  printf("%s", *(fakefile -> curr -> dependencies)++);
	  if (*(fakefile -> curr -> dependencies) != NULL){
	    
	    printf(" ");
	  }  
	}
	printf("\n");
	
	printf("\t");
	while (*(fakefile -> curr -> action_line) != NULL){
	  printf("%s", *(fakefile -> curr -> action_line)++);
	  if (*(fakefile -> curr -> action_line) != NULL){
	    
	    printf(" ");
	  } 
	}
	
	if (fakefile -> curr -> next_elem != NULL){
	  printf("\n");
	  printf("\n");
	  
	}
	else {
	  printf("\n");
	}
	fakefile -> curr = fakefile -> curr -> next_elem;
	
      }
    }
  }
}

/*
  This functions main point is to check how mnay dependencies are at a 
  designated rule
*/
int num_dependencies(Fakefile *const fakefile, int rule_num){
  int i, k, j = 0;
  char **temp_deps;
  
  
  if (fakefile == NULL || rule_num < 0){
    return -1;
  }
  fakefile -> curr = fakefile -> root;

  for (i = 0; i < rule_num; i++){
    fakefile -> curr = fakefile -> curr -> next_elem;
    
  }
  temp_deps = fakefile -> curr -> dependencies;
  while (*temp_deps != NULL){
     j++;
     (temp_deps)++; 

   }
   
   k = j - 1;
   fakefile -> curr -> dependency_count = k;
   
   return k;
}

/*
  The point of this function is to get a specific dependency from a specific 
  rule
*/
char *get_dependency(Fakefile *const fakefile, int rule_num, 
int dependency_num){
  int i;
  fakefile -> curr = fakefile -> root;
 
  if (fakefile == NULL || rule_num < 0 || dependency_num < 0){
    
    return NULL;
  }
  
  else {

    for (i = 0; i < rule_num; i++){
      fakefile -> curr = fakefile -> curr -> next_elem;
    }
    
    return (fakefile -> curr -> dependencies[dependency_num + 1]);
  }
  return NULL;
}

/*
  This function handles all of the process control and the parent, 
  child breaking up
*/
int do_action(Fakefile *const fakefile, int rule_num){

  Rule *curr_rule;
  pid_t pid;
  int result = 0;
  int num_of_rules, i;
  
  fakefile -> curr = fakefile -> root;
  
  while (fakefile -> curr -> next_elem != NULL){
    
    num_of_rules++;
    fakefile -> curr = fakefile -> curr -> next_elem;
  }
  num_of_rules++;
  
  
  if (fakefile == NULL || rule_num < 0|| rule_num > num_of_rules){
    return -1;
    
  }
  
  pid = safe_fork();
  curr_rule = fakefile -> root;
  
  for(i = 0; i < rule_num; i++){
    curr_rule = curr_rule -> next_elem;
  }
  
  if(pid == 0){
    execvp(curr_rule -> action_line[0], curr_rule -> action_line);
    
  }
  else if (pid > 0){
    wait(&result);
    
    if (WEXITSTATUS(result) == 0 && WIFEXITED(result) > 0){
      return result;
    }
    
  }
  
  return -1;
}

void clear_fakefile(Fakefile **const fakefile){
  if(fakefile != NULL || *fakefile != NULL){
    
    /* free(*fakefile -> root);
       free(*fakefile -> curr);
       free(*fakefile -> next);
    free(*fakefile);*/
    
  }
  
}

