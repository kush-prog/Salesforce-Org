// Task 1: Print Open Courses starting in the next 30 days
System.debug('--- TASK 1 ---');
List<Course__c> openCourses = [
    SELECT Id, Name, Start_Date__c 
    FROM Course__c 
    WHERE Status__c = 'Open' AND Start_Date__c = NEXT_N_DAYS:30
];
for (Course__c c : openCourses) {
    System.debug('Course: ' + c.Name + ' | Date: ' + c.Start_Date__c);
}

// Task 3: Parent-to-Child Query (Course with Enrolled Students)
System.debug('--- TASK 3 ---');
List<Course__c> coursesWithStudents = [
    SELECT Id, Name, (SELECT Id, Student__r.Name FROM Enrollments__r) 
    FROM Course__c
];
for (Course__c c : coursesWithStudents) {
    System.debug('Course Name: ' + c.Name);
    for (Enrollment__c e : c.Enrollments__r) {
        System.debug(' -> Student: ' + e.Student__r.Name);
    }
}

// Task 5: SOSL Search for 'John'
System.debug('--- TASK 5 ---');
List<List<sObject>> searchResults = [
    FIND 'John' IN NAME FIELDS RETURNING Student__c(Id, Name), Faculty__c(Id, Name)
];
System.debug('Students Found: ' + searchResults[0]);
System.debug('Faculty Found: ' + searchResults[1]);

// Task 7: Call CourseUtility.getOpenCourses()
System.debug('--- TASK 7 ---');
List<Course__c> classResults = CourseUtility.getOpenCourses();
for (Course__c c : classResults) {
    System.debug('Class Method Result - Course: ' + c.Name);
}