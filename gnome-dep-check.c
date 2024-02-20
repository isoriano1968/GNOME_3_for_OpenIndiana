/* 
 * Iggi's dirty solaris-gnome-dependencies file parser
 * 
 * 21.02.2024
 */
 
 
#include <stdio.h>
#include <string.h>
#include <stdbool.h>

#define MAX_LINE_LENGTH 1024
#define MAX_LINES 4096
#define OCCURENCES 1024

bool foundOccurence = false; 


int main() 
{
    char lines[MAX_LINES][MAX_LINE_LENGTH];
    char dependency[OCCURENCES][MAX_LINE_LENGTH];
    int num_lines = 0;

    FILE *file = fopen("solaris-gnome-dependencies", "r");  // replace 'your_file' with your filename
    
    if (file == NULL) 
    {
        printf("Could not open file\n");
        return 1;
    }

    // Read the file line by line into a string array
    while (fgets(lines[num_lines], sizeof(lines[num_lines]), file) && num_lines < MAX_LINES) 
    {
        num_lines++;
    }
    fclose(file);

    // Process each element in the array
    for (int i = 0; i < num_lines; i++) 
    {
        char *right_part = strchr(lines[i], '+');
        
        if (right_part != NULL && *(right_part + 1) == '=') 
        {
            right_part += 2;  // skip past the '+='
            char *last_string = strrchr(right_part, '/');
            
            if (last_string != NULL) 
            {
                last_string++;  // skip past the '/'
                char *newline = strchr(last_string, '\n');
                
                if (newline != NULL) 
                {
                    *newline = '\0';  // remove the newline at the end
                }

                printf("Searching for: %s\n", last_string);

                // Now check if any other line starts with last_string
                for (int j = 0; j < num_lines; j++) 
				{
                    if (j != i && strncmp(lines[j], last_string, strlen(last_string)) == 0) 
                    {
                        if (foundOccurence == false)
						{
							// printf("Match found in array element %d:\n%s", j, lines[j]);
                    		foundOccurence = true;
                    		if(strncmp(dependency[j], last_string, strlen(last_string)))
                    		{
								char tempStr[768];
								
								strcpy(tempStr, last_string);
								strcat(tempStr, " in ");
								strcat(tempStr, lines[i]);
								strcat(tempStr, " needs ");
								strcat(tempStr, last_string);
								
								strcpy(dependency[i], tempStr);
								printf("%s \n", dependency[i]);
							}
							else
							{
								printf("Dort\n");
								strcpy(dependency[j], last_string);
							}
                    		
						}
					}
                }
          	// printf("\nNo further match found!\n");  
			foundOccurence = false;
			}
        }
    }
    
    return 0;
}

