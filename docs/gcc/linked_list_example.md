
# Generic Linked List example.

## Simple generic example

```c
#include <stdio.h>
#include <stdlib.h>

## ref: https://www.geeksforgeeks.org/generic-linked-list-in-c-2/

typedef struct node {
	void* data;
	struct node* next;
} Node;

typedef struct list {
	int size;
	Node* head;
} List;

List* create_list() {
	List* new_list = (List*)malloc(sizeof(List));
	new_list->size = 0;
	new_list->head = NULL;
	return new_list;
}

void add_to_list(List* list, void* data) {
	Node* new_node = (Node*)malloc(sizeof(Node));
	new_node->data = data;
	new_node->next = list->head;
	list->head = new_node;
	list->size++;
}

void* remove_from_list(List* list) {
	if (list->size == 0) {
		return NULL;
	}
	Node* node_to_remove = list->head;
	void* data = node_to_remove->data;
	list->head = node_to_remove->next;
	free(node_to_remove);
	list->size--;
	return data;
}

void free_list(List* list) {
	Node* current_node = list->head;
	while (current_node != NULL) {
		Node* next_node = current_node->next;
		free(current_node);
		current_node = next_node;
	}
	free(list);
}

int main() {
	// create a new list
	List* int_list = create_list();
	
	// add some integers to the list
	int x = 42;
	add_to_list(int_list, (void*)&x);
	int y = 13;
	add_to_list(int_list, (void*)&y);
	int z = 99;
	add_to_list(int_list, (void*)&z);
	
	// remove the integers from the list and print them
	int* int_ptr = NULL;
	while ((int_ptr = (int*)remove_from_list(int_list)) != NULL) {
		printf("%d\n", *int_ptr);
	}
	
	// free the memory used by the list
	free_list(int_list);
	
	return 0;
}

```

## Another Example

Following code for project which reads data from a .txt file and creates linked list of structures for 2 different 
operations on that structures (CRUD). 

The file contains data of rooms in a hotel and its guests with below pattern:

```output
---
203
1
103.52
#
Michal Novak
Malinova 97, Bratislava
20210114
20210119
---
105
2
323
#
Tomas Kovac
Jahodova 3, Bratislava
20210204
20210302
#
Lucia Kovacova
Jahodova 3, Bratislava
20210204
20210302
```

In the file each room record starts with --- and each guest record starts with #. 
Each line of file has data of one property (different datatypes) of room or guest.

Following is example code to create the linked list and print; however, it could use enhancement due to use of 
global variables in the printGuest() function.

Instead the printGuest() function should take a parameter as the head of Guest linked list and traverse it. 


```c
#include <stdio.h>
#include <stdlib.h>     
#include <string.h>    
#include <ctype.h>      
#include <errno.h>      

#define FILE_NAME "hotel.txt"
#define MAXC   1024     /* if you need a constant, #define one (or more) */

## ref: https://codereview.stackexchange.com/questions/260164/how-to-have-a-nested-struct-as-linked-list-in-c

typedef struct Guest {
    char* name;
    char* address;
    int beginningOfReservation;
    int endOfreservation;
    struct Guest *next;
} Guest;

typedef struct Room {
    int roomNo;
    int numberOfBeds;
    double price;
    struct Guest *guests;
    struct Room *next; 
} Room;

Room *head = NULL;
Room *current = NULL;

Guest *gstHead = NULL;
Guest *gstCurrent = NULL;

int get_file_line_count() {
    FILE *myFile;
    char line[100];
    int fileLineNumber = 0;
    myFile = fopen(FILE_NAME, "r");
    if(!myFile) {
        printf("file not opened corectly!\n");
        exit(0);
    }
    while(feof(myFile) == 0) {
        fgets(line, 99, myFile);
        fileLineNumber++;
    }
    fclose(myFile);
    return fileLineNumber;
}

void insertRoom(int roomNo, int noOfBed, double price, Guest *geusts){
    Room *hotelRoom = (Room*) malloc(sizeof(Room));
    hotelRoom->roomNo = roomNo;
    hotelRoom->numberOfBeds = noOfBed;
    hotelRoom->price = price;
    hotelRoom->guests = geusts;
    tail->next = hotelRoom;
    if (head == NULL) {
        head = hotelRoom;
    }    
}

void insertGeust(char* name, char* address, int startDate, int endDate){
    Guest *gst = (Guest*) malloc(sizeof(Guest));
    gst->name = name;
    gst->address = address;
    gst->beginningOfReservation = startDate;
    gst->endOfreservation = endDate;
    gstTail->next = gst;
    if (gstHead == NULL) {
        gstHead = gst;
    }    
}

void n() {
    int counter = 0;
    int firstCounter = 0;
    int secondCounter = 0;
    int hashCounter = 0;
    int lineCounter = 0;
    char line[MAXC];

    FILE *fp = fopen(FILE_NAME, "r");
    if (!fp) { 
        perror ("file open failed");
    }

    int roomNo;
    int noOfBed;
    double price;
    char name[100];
    char address[100];
    int startDate;
    int endDate;
    while(feof(fp) == 0) {
        fgets(line, 99, fp);
        switch (firstCounter)
        {
            case 1:
                roomNo = atoi(line);
                break;
            case 2:
                noOfBed = atoi(line);
                break;
            case 3:
                sscanf(line, "%lf", &price);
                break;
            default:
                break;
        }
        switch (secondCounter)
        {
            case 1:
                sscanf(line, "%[^\n]s", name);
                break;
            case 2:
                sscanf(line, "%[^\n]s", address);
                break;
            case 3:
                startDate = atoi(line);
                break;
            case 4:
                endDate = atoi(line);
                break;
            default:
            break;
        }
        if (strcmp("---\n", line) == 0) {
            hashCounter = 0;
            firstCounter = 0;
            secondCounter = 0;
            lineCounter++;
            gstHead = NULL;
            gstCurrent = NULL;
            if(lineCounter > 1){
                insertGeust(name, address, startDate, endDate);
                insertRoom(roomNo, noOfBed, price, gstHead);
            }
        }
        if (strcmp("#\n", line) == 0) {
            hashCounter++;
            if(hashCounter > 1){
                insertGeust(name, address, startDate, endDate);
            }
            secondCounter = 0;
        }
        
        if (feof(fp) != 0){
            firstCounter = 0;
            hashCounter = 0;
            lineCounter++;
            if(lineCounter > 1){
                insertGeust(name, address, startDate, endDate);
                insertRoom(roomNo, noOfBed, price, gstHead);
            }
        }
        firstCounter++;
        secondCounter++;
        counter++;
    }
    if (fp != stdin){
        fclose (fp);
    }
}

void printRoom(){
    struct Room *ptr = head;
    while(ptr !=NULL){
        printf("\n%d", ptr->roomNo);
        printf("\n%d", ptr->numberOfBeds);
        printf("\n%lf", ptr->price);
        printGuest();
        ptr = ptr->next;
    }
}

void printGuest(){
    struct Guest *ptrr = gstHead;
    while (ptrr != NULL)
    {
        printf("\n%s", ptrr->name);
        printf("\n%s", ptrr->address);
        printf("\n%d", ptrr->beginningOfReservation);
        printf("\n%d", ptrr->endOfreservation);
        ptrr = ptrr->next;
    }  
}

int length() {
    int length = 0;
    struct Guest *curr;
    for(curr = gstHead; curr != NULL; curr = curr->next){
        length++;
    }
    return length;
}

int main(int argc, char **argv) {
    char operation;
    int fileLineNumber;
    do {
        printf("\n\nSelect the operation you want to do from the following list: \n\n");
        printf("For Summary Type s\n");
        scanf(" %c", &operation);
        fileLineNumber = get_file_line_count();
        n();
        printRoom();
        // printGuest();
        // free(hotelRoom);
    } while (operation != 'x' || operation != 'X');

    return 0;
}

```


## Reference

- https://www.geeksforgeeks.org/generic-linked-list-in-c-2/
- https://codereview.stackexchange.com/questions/260164/how-to-have-a-nested-struct-as-linked-list-in-c

The following example is not as helpful due to being quite convoluted
- https://stackoverflow.com/questions/23279119/creating-and-understanding-linked-lists-of-structs-in-c
- http://www.mahonri.info/SO/23279119_LinkedList_101.c
- 

