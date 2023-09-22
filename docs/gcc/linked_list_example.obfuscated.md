
```c
/*****************************************************************************
** File: LinkedList_101.c
**
** Demonstrates a single-linked list implementation.
*/

/*****************************************************************************
** Compiler setup.
*/

/*-------------------------------------------------------------------------
** Required header files.
*/
#include <stdlib.h>  // malloc(), NULL, ...
#include <stdio.h>   // fprintf(), stderr, snprintf(), printf(), ...
#include <errno.h>   // ENOMEM, ENOENT, ...
#include <string.h>  // strcmp()...

/*-------------------------------------------------------------------------
** Linked-list (example) types.
*/
typedef struct NODE_PAYLOAD_S
{
   /* Data Payload (defined by coder) */
   char name[10];
   char desc[10];
   int hours;
   int workordernum;
} NODE_PAYLOAD_T;

typedef struct LIST_NODE_S
{
   /* Next-node pointer */
   struct LIST_NODE_S *next;     /* pointer to the next node in the list. */
   NODE_PAYLOAD_T      payload;  /* Data Payload (defined by coder) */
} LIST_NODE_T;

/*****************************************************************************
** Allocate, initialize, and insert a new node at the list head.
*/
int LIST_InsertHeadNode(
      LIST_NODE_T **IO_head,
      char         *I__name,
      char         *I__desc,
      int           I__hours,
      int           I__workordernum
      )
{
   int rCode=0;
   LIST_NODE_T *newNode = NULL;

   /* Allocate memory for new node (with its payload). */
   newNode=malloc(sizeof(*newNode));
   if(NULL == newNode)
      {
      rCode=ENOMEM;   /* ENOMEM is defined in errno.h */
      fprintf(stderr, "malloc() failed.\n");
      goto CLEANUP;                        
      }

   /* Initialize the new node's payload. */
   snprintf(newNode->payload.name, sizeof(newNode->payload.name), "%s", I__name);
   snprintf(newNode->payload.desc, sizeof(newNode->payload.desc), "%s", I__desc);
   newNode->payload.hours = I__hours;
   newNode->payload.workordernum = I__workordernum;

   /* Link this node into the list as the new head node. */
   newNode->next = *IO_head;
   *IO_head = newNode;

CLEANUP:

   return(rCode);
}

/*****************************************************************************
** Print the payloads of each node (from head to tail) in a linked list.
*/
int PrintListPayloads(
      LIST_NODE_T *head
      )
{
   int rCode=0;
   LIST_NODE_T *cur = head;
   int nodeCnt=0;

   while(cur)
      {
      ++nodeCnt;
      printf("%s, %s, %d, %d\n",
            cur->payload.name,
            cur->payload.desc,
            cur->payload.hours,
            cur->payload.workordernum
            );
       cur=cur->next;
       }

    printf("%d nodes printed.\n", nodeCnt);

   return(rCode);
}

/*****************************************************************************
** Get the last list node by walking the list.
*/
int LIST_GetTailNode(
      LIST_NODE_T  *I__listHead,   /* The caller supplied list head pointer. */
      LIST_NODE_T **_O_listTail    /* The function sets the callers pointer to the last node. */
      )
{
   int rCode=0;
   LIST_NODE_T *curNode = I__listHead;

   /* Iterate through all list nodes until the last node is found. */
   /* The last node's 'next' field, which is always NULL. */
   if(curNode)
      {
      while(curNode->next)
         curNode=curNode->next;
      }

   /* Set the caller's pointer to point to the last (ie: tail) node. */
   if(_O_listTail)
      *_O_listTail = curNode;

   return(rCode);
}

/*****************************************************************************
** Allocate, initialize, and insert a new node at the list tail.
*/
int LIST_InsertTailNode(
      LIST_NODE_T **IO_head,
      char         *I__name,
      char         *I__desc,
      int           I__hours,
      int           I__workordernum
      )
{
   int rCode=0;
   LIST_NODE_T *tailNode;
   LIST_NODE_T *newNode = NULL;

   /* Get a pointer to the last node in the list. */
   rCode=LIST_GetTailNode(*IO_head, &tailNode);
   if(rCode)
{
      fprintf(stderr, "LIST_GetTailNode() reports: %d\n", rCode);
      goto CLEANUP;
}

   /* Allocate memory for new node (with its payload). */
   newNode=malloc(sizeof(*newNode));
   if(NULL == newNode)
{
      rCode=ENOMEM;   /* ENOMEM is defined in errno.h */
      fprintf(stderr, "malloc() failed.\n");
      goto CLEANUP;
}

   /* Initialize the new node's payload. */
   snprintf(newNode->payload.name, sizeof(newNode->payload.name), "%s", I__name);
   snprintf(newNode->payload.desc, sizeof(newNode->payload.desc), "%s", I__desc);
   newNode->payload.hours = I__hours;
   newNode->payload.workordernum = I__workordernum;

   /* Link this node into the list as the new tail node. */
   newNode->next = NULL;
   if(tailNode)
      tailNode->next = newNode;
   else
      *IO_head = newNode;

CLEANUP:

   return(rCode);
}      

/*****************************************************************************
** Find a node with a payload->name string greater than the I__name string.
*/
int LIST_FetchParentNodeByName(
      LIST_NODE_T *I__head,
      const char  *I__name,
      LIST_NODE_T **_O_parent
      )
{
   int rCode=0;
   LIST_NODE_T *parent = NULL;
   LIST_NODE_T *curNode = I__head;

   /* Inform the caller of an 'empty list' condition. */
   if(NULL == I__head)
{
      rCode=ENOENT;
      goto CLEANUP;
}

   /* Find a node with a payload->name string greater than the I__name string */
   while(curNode)
{
      if(strcmp(curNode->payload.name, I__name) > 0)
         break;

      parent = curNode; /* Remember this node. It is the parent of the next node. */
      curNode=curNode->next;  /* On to the next node. */
}

   /* Set the caller's 'parent' pointer. */
   if(_O_parent)
      *_O_parent = parent;

CLEANUP:

   return(rCode);
}

/*****************************************************************************
** Allocate, initialize, and insert a new node in an ordered list.
*/
int LIST_InsertNodeByName(
      LIST_NODE_T **IO_head,
      char         *I__name,
      char         *I__desc,
      int           I__hours,
      int           I__workordernum
      )
{
   int rCode=0;
   LIST_NODE_T *parent;
   LIST_NODE_T *newNode = NULL;

   /* Allocate memory for new node (with its payload). */
   newNode=malloc(sizeof(*newNode));
   if(NULL == newNode)
      {
      rCode=ENOMEM;   /* ENOMEM is defined in errno.h */
      fprintf(stderr, "malloc() failed.\n");
      goto CLEANUP;
      }

   /* Initialize the new node's payload. */
   snprintf(newNode->payload.name, sizeof(newNode->payload.name), "%s", I__name);
   snprintf(newNode->payload.desc, sizeof(newNode->payload.desc), "%s", I__desc);
   newNode->payload.hours = I__hours;
   newNode->payload.workordernum = I__workordernum;

   /* Find the proper place to link this node */
   rCode=LIST_FetchParentNodeByName(*IO_head, I__name, &parent);
   switch(rCode)
      {
      case 0:
         break;

      case ENOENT:
         /* Handle empty list condition */
         newNode->next = NULL;
         *IO_head = newNode;
         rCode=0;
         goto CLEANUP;

      default:
         fprintf(stderr, "LIST_FetchParentNodeByName() reports: %d\n", rCode);
         goto CLEANUP;
      }

   /* Handle the case where all current list nodes are greater than the new node. */
   /* (Where the new node will become the new list head.) */
   if(NULL == parent)
      {
      newNode->next = *IO_head;
      *IO_head = newNode;
      goto CLEANUP;
      }

   /* Final case, insert the new node just after the parent node. */
   newNode->next = parent->next;
   parent->next = newNode;

CLEANUP:

   return(rCode);
}

/*****************************************************************************
** Find a specific node by name.
*/
int LIST_FetchNodeByName(
      LIST_NODE_T  *I__head,
      const char   *I__name,
      LIST_NODE_T **_O_node,
      LIST_NODE_T **_O_parent
      )
{
   int rCode=0;
   LIST_NODE_T *parent = NULL;
   LIST_NODE_T *curNode = I__head;

   /* Search the list for a matching payload name. */
   while(curNode)
      {
      if(0 == strcmp(curNode->payload.name, I__name))
         break;

      parent = curNode;   /* Remember this node; it will be the parent of the next. */
      curNode=curNode->next;
      }

   /* If no match is found, inform the caller. */
   if(NULL == curNode)
     {
     rCode=ENOENT;
     goto CLEANUP;
     }

   /* Return the matching node to the caller. */
   if(_O_node)
      *_O_node = curNode;

   /* Return parent node to the caller. */
   if(_O_parent)
      *_O_parent = parent;

CLEANUP:

   return(rCode);
}

/*****************************************************************************
** Locate a specific node by name, unlink it from the list, and free it.
*/
int LIST_DeleteNodeByName(
      LIST_NODE_T **IO_head,
      char         *I__name
      )
{
   int rCode=0;
   LIST_NODE_T *parent;
   LIST_NODE_T *delNode = NULL;

   /* Find the node to delete. */
   rCode=LIST_FetchNodeByName(*IO_head, I__name, &delNode, &parent);
   switch(rCode)
      {
      case 0:
         break;

      case ENOENT:
         fprintf(stderr, "Matching node not found.\n");
         goto CLEANUP;

      default:
         fprintf(stderr, "LIST_FetchNodeByName() reports: %d\n", rCode);
         goto CLEANUP;
      }

   /* Unlink the delNode from the list. */
   if(NULL == parent)
      *IO_head = delNode->next;
   else
      parent->next = delNode->next;

   /* Free the delNode and its payload. */
   free(delNode);

CLEANUP:

   return(rCode);
}

/*****************************************************************************
** Free all list nodes (from head to tail).
*/
int LIST_Destroy(
      LIST_NODE_T **IO_head
      )
{
   int rCode=0;

   while(*IO_head)
      {
      LIST_NODE_T *delNode = *IO_head;
   
      *IO_head = (*IO_head)->next;   
      free(delNode);
      }
   
   return(rCode);
}
      
/*****************************************************************************
** Program start.
*/
int main(void)
{
   int rCode=0;
   LIST_NODE_T *listHead = NULL;

   /* Insert a linked-list node. */
   rCode=LIST_InsertHeadNode(&listHead, "Mahonri", "Jareds Bro", 4, 2421);
   if(rCode)
      {
      fprintf(stderr, "LIST_InsertHeadNode() reports: %d\n", rCode);
      goto CLEANUP;
      }

   /* Insert a linked-list node. */
   rCode=LIST_InsertNodeByName(&listHead, "Joe", "CEO", 5, 2419);
   if(rCode)
      {
      fprintf(stderr, "=LIST_InsertNodeByName() reports: %d\n", rCode);
      goto CLEANUP;
      }

   /* Insert a linked-list node. */
   rCode=LIST_InsertNodeByName(&listHead, "Adam", "All men", 5, 2419);
   if(rCode)
      {
      fprintf(stderr, "LIST_InsertNodeByName() reports: %d\n", rCode);
      goto CLEANUP;
      }

   /* Insert a linked-list node. */
   rCode=LIST_InsertNodeByName(&listHead, "Eve", "Mother", 24, 2);
   if(rCode)
      {
      fprintf(stderr, "LIST_InsertNodeByName() reports: %d\n", rCode);
      goto CLEANUP;
      }

   rCode=LIST_DeleteNodeByName(&listHead, "Adam");
   if(rCode)
      {
      fprintf(stderr, "LIST_DeleteNodeByName() reports: %d\n", rCode);
      goto CLEANUP;
      }
      
   rCode=LIST_InsertTailNode(&listHead, "Omega", "[The End]", 29, 3);
   if(rCode)
      {
      fprintf(stderr, "LIST_InsertNodeByName() reports: %d\n", rCode);
      goto CLEANUP;
      }

   rCode=PrintListPayloads(listHead);
   if(rCode)
      {
      fprintf(stderr, "PrintListPayloads() reports: %d\n", rCode);
      goto CLEANUP;
      }

CLEANUP:

   if(listHead)
      {
      int rc=LIST_Destroy(&listHead);
      if(rc)
         {
         fprintf(stderr, "LIST_Destroy() reports: %d\n", rc);
         if(!rCode)
            rCode=rc;
         }
      }

   return(rCode);
}

```

## Reference

- https://stackoverflow.com/questions/23279119/creating-and-understanding-linked-lists-of-structs-in-c
- http://www.mahonri.info/SO/23279119_LinkedList_101.c
- https://www.cs.cmu.edu/~guna/15-123S11/Lectures/Lecture09.pdf
- 

