public with sharing class CourseUtility {
    
    public static List<Course__c> getOpenCourses() {
        return [
            SELECT Id, Name, Start_Date__c, Status__c 
            FROM Course__c 
            WHERE Status__c = 'Open' 
              AND Start_Date__c = NEXT_N_DAYS:30
        ];
    }
}