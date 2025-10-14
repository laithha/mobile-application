Task priority app
it helps users to manage tasks with assigning priority levels(high, medium ,low)
you can view , create, filter by priority, delete tasks while organizing them by importance
The goal is to help me focus on what matters most first.

crud operations:
-create
    it creates a new task with title , description , priority level

-Read
    views all of the tasks sorted by priority level

-update
    edit tasks details 

-delete
    remove finished or unnecessary tasks

Local Database: stores tasks for offline access

updates remote data when online

At least create, update, and delete are persisted both locally and remotely

Offline Behavior

Tasks added offline stay in local storage

Updates and deletes sync once online

You can always read local data

DB
int id ------> unique identifier
title varchar(50)------> title of the task (assingment or cleaning)
description varchar(100)-------> description of the task that needs to be done
priority varchar(10) -------> based on priorities ( high, medium , low)
status varchar(50) -------> is the task done? or not 