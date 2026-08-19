// Service class containing all business logic for Enrollment/Course capacity management. Called by EnrollmentTriggerHandler.
// No SOQL lives here directly — all queries go through EnrollmentSelector.

public with sharing class EnrollmentService {

    private static final String STATUS_CLOSED = 'Closed';
    private static final String STATUS_OPEN = 'Open';

    // If a Course's enrollment count reaches its Capacity after an insert, close the course and notify the admin. 
    // Uses exactly 1 SOQL query (via selector) and 1 DML statement.
    public static void closeCoursesAtFullCapacity(List<Enrollment__c> newEnrollments) {
        Set<Id> courseIds = collectCourseIds(newEnrollments);
        if (courseIds.isEmpty()) {
            return;
        }

        List<Course__c> courses = EnrollmentSelector.getCoursesWithEnrollmentsByIds(courseIds);

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

            Set<Id> closedCourseIds = new Set<Id>();
            for (Course__c course : coursesToClose) {
                closedCourseIds.add(course.Id);
            }
            EnrollmentNotificationService.logCourseClosedEmail(closedCourseIds);
        }
    }

    // If a Course was Closed and a deletion drops its enrollment count below Capacity, reopen the course.
    // Uses exactly 1 SOQL query (via selector) and 1 DML statement.

    public static void reopenCoursesBelowCapacity(List<Enrollment__c> deletedEnrollments) {
        Set<Id> courseIds = collectCourseIds(deletedEnrollments);
        if (courseIds.isEmpty()) {
            return;
        }

        List<Course__c> closedCourses = EnrollmentSelector.getClosedCoursesWithEnrollmentsByIds(courseIds);

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

    private static Set<Id> collectCourseIds(List<Enrollment__c> enrollments) {
        Set<Id> courseIds = new Set<Id>();
        for (Enrollment__c enrollment : enrollments) {
            if (enrollment.Course__c != null) {
                courseIds.add(enrollment.Course__c);
            }
        }
        return courseIds;
    }
}