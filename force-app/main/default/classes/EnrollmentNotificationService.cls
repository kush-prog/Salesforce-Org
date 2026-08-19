// Handles asynchronous notification logic related to Enrollment/Course events. 
// Sends a real email to the admin (with a CC'd user) when a Course closes.
public class EnrollmentNotificationService {
    
    private static final String ADMIN_EMAIL = 'kush.chauhan@symbtechnologies.com';
    private static final String CC_EMAIL = 'Arpit.Sharma@symbtechnologies.com';

    // Logs a mock email body for each course that was just closed. Runs asynchronously so it doesn't add to the trigger's synchronous governor limits. 
    // courseIds Ids of Course__c records that were just closed.
    @future
    public static void logCourseClosedEmail(Set<Id> courseIds) {
        List<Course__c> courses = [SELECT Id, Name FROM Course__c WHERE Id IN :courseIds];

        if (courses.isEmpty()) {
            return;
        }

        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        for (Course__c course : courses) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String>{ ADMIN_EMAIL });
            email.setCcAddresses(new List<String>{ CC_EMAIL });
            email.setSubject('Course Closed: ' + course.Name);
            email.setPlainTextBody(
                'The course "' + course.Name + '" (Id: ' + course.Id + ') has reached full capacity ' +
                'and its status has been updated to Closed.\n\n' +
                'This is an automated system notification.'
            );
            // Not tied to a specific record, so don't try to log it as an Activity
            email.setSaveAsActivity(false);

            emailsToSend.add(email);
        }

        if (!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend);
        }
    }
}