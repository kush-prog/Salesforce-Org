// Selector class for Enrollment/Course related queries. This is the ONLY place SOQL related to this feature should live. No business logic belongs here — just data retrieval.

public with sharing class EnrollmentSelector {
    
    // Fetches Courses (with their child Enrollments) for the given Ids. Used after an insert to check if any course just became full.
    public static List<Course__c> getCoursesWithEnrollmentsByIds(Set<Id> courseIds) {
        return [
            SELECT Id, Capacity__c, Status__c, (SELECT Id FROM Enrollments__r)
            FROM Course__c
            WHERE Id IN :courseIds
        ];
    }

    // Fetches only Courses that are currently Closed, among the given Ids, along with their child Enrollments. Used after a delete to check if a closed course now has room again.
    public static List<Course__c> getClosedCoursesWithEnrollmentsByIds(Set<Id> courseIds) {
        return [
            SELECT Id, Capacity__c, Status__c, (SELECT Id FROM Enrollments__r)
            FROM Course__c
            WHERE Id IN :courseIds AND Status__c = 'Closed'
        ];
    }
}