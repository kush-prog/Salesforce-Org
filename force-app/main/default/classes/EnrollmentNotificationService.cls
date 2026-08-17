// Handles asynchronous notification logic related to Enrollment/Course events. Currently logs a mock email body when a Course transitions to Closed.
 
public with sharing class EnrollmentNotificationService {

    // Logs a mock email body for each course that was just closed. Runs asynchronously so it doesn't add to the trigger's synchronous governor limits. 
    // courseIds Ids of Course__c records that were just closed.
    @future
    public static void logCourseClosedEmail(Set<Id> courseIds) {
        List<Course__c> courses = [SELECT Id, Name FROM Course__c WHERE Id IN :courseIds];

        for (Course__c course : courses) {
            String mockEmailBody =
                'Subject: Course Closed Notification\n\n' +
                'The course "' + course.Name + '" (Id: ' + course.Id + ') has reached full capacity ' +
                'and its status has been updated to Closed.\n\n' +
                'This is an automated system notification.';

            System.debug(LoggingLevel.INFO, '--- MOCK EMAIL LOG ---\n' + mockEmailBody);
        }
    }
}