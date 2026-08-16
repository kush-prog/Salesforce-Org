// Handler class for EnrollmentTrigger. Enrollment__c is a junction object between Student__c and Course__c. 
// Keeps Course__c Status__c in sync with seat availability: closes a course once it hits Max Seats, 
// reopens it if a cancellation drops the count back below Max Seats.
 
public with sharing class EnrollmentTriggerHandler {

    private static final String STATUS_CLOSED = 'Closed';
    private static final String STATUS_OPEN = 'Open';

    public void run() {
        if (!Trigger.isAfter) {
            return;
        }

        if (Trigger.isInsert) {
            onAfterInsert((List<Enrollment__c>) Trigger.new);
        } else if (Trigger.isUpdate) {
            onAfterUpdate((List<Enrollment__c>) Trigger.new, (Map<Id, Enrollment__c>) Trigger.oldMap);
        } else if (Trigger.isDelete) {
            onAfterDelete((List<Enrollment__c>) Trigger.old);
        }
    }

    // If a Course's enrollment count reaches its Capacity after this insert, close the course. Uses exactly 1 SOQL query and 1 DML statement.

    public void onAfterInsert(List<Enrollment__c> newList) {
        Set<Id> courseIds = collectCourseIds(newList);
        if (courseIds.isEmpty()) {
            return;
        }

        // Single SOQL: fetch each affected course along with its current enrollment count
        List<Course__c> courses = [
            SELECT Id, Capacity__c, Status__c, (SELECT Id FROM Enrollments__r)
            FROM Course__c
            WHERE Id IN :courseIds
        ];

        List<Course__c> coursesToClose = new List<Course__c>();
        for (Course__c course : courses) {
            Integer enrolledCount = course.Enrollments__r.size();

            Boolean isFull = course.Capacity__c != null
                && enrolledCount == Integer.valueOf(course.Capacity__c);
            Boolean alreadyClosed = course.Status__c == STATUS_CLOSED;

            if (isFull && !alreadyClosed) {
                coursesToClose.add(new Course__c(Id = course.Id, Status__c = STATUS_CLOSED));
            }
        }

        if (!coursesToClose.isEmpty()) {
            update coursesToClose;
        }
    }

    // Placeholder for future update-related requirements. No behavior defined yet for this event.
    public void onAfterUpdate(List<Enrollment__c> newList, Map<Id, Enrollment__c> oldMap) {
        // No requirement specified for this event yet.
    }

    // If a Course was Closed and this deletion drops its enrollment count below Max Seats, reopen the course. Uses exactly 1 SOQL query and 1 DML statement.
    public void onAfterDelete(List<Enrollment__c> oldList) {
        Set<Id> courseIds = collectCourseIds(oldList);
        if (courseIds.isEmpty()) {
            return;
        }

        // Single SOQL: only pull courses that are currently Closed, Since only those are eligible to reopen
        List<Course__c> closedCourses = [
            SELECT Id, Capacity__c, Status__c, (SELECT Id FROM Enrollments__r)

            FROM Course__c
            WHERE Id IN :courseIds AND Status__c = :STATUS_CLOSED
        ];

        List<Course__c> coursesToReopen = new List<Course__c>();
        for (Course__c course : closedCourses) {
            Integer enrolledCount = course.Enrollments__r.size();

            Boolean isBelowCapacity = course.Capacity__c != null
                && enrolledCount < Integer.valueOf(course.Capacity__c);

            if (isBelowCapacity) {
                coursesToReopen.add(new Course__c(Id = course.Id, Status__c = STATUS_OPEN));
            }
        }

        if (!coursesToReopen.isEmpty()) {
            update coursesToReopen;
        }
    }

    private Set<Id> collectCourseIds(List<Enrollment__c> enrollments) {
        Set<Id> courseIds = new Set<Id>();
        for (Enrollment__c enrollment : enrollments) {
            if (enrollment.Course__c != null) {
                courseIds.add(enrollment.Course__c);
            }
        }
        return courseIds;
    }
}